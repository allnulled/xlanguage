window.pegeditors = {};

class PegEditor {

	constructor(originalElement, options = {}) {
		const defaultOptions = {
			lineNumbers: true,
			width: "100%",
			height: "100%",
			styleSelectedText: true
		};
		this.htmlOriginal = originalElement;
		this.jOriginal = jQuery(originalElement);
		this.id = options.id || this.jOriginal.attr("data-pegeditor-id") || "";
		this.grammar = options.grammar || this.jOriginal.attr("data-pegeditor-grammar") || "";
		this.theme = options.theme || this.jOriginal.attr("data-pegeditor-theme") || "";
		this.settings = options.settings || this.jOriginal.attr("data-pegeditor-settings") || "";
		this.options = Object.assign({}, options.options || {}, defaultOptions, ((editor) => {
			try {
				return JSON.parse(editor.settings);
			} catch (error) {
				return {};
			}
		})(this));
		this.instance = CodeMirror.fromTextArea(this.htmlOriginal, this.options);
		this.htmlEditor = this.instance.getWrapperElement();
		this.jEditor = jQuery(this.htmlEditor);
		const htmlErrorMessage = jQuery("<div class='ErrorMessage'><div class='SuggestionsBox'></div><div class='MessageBox'></div></div>");
		this.jEditor.append(htmlErrorMessage);
		this.htmlErrorMessage = htmlErrorMessage;
		this.jErrorMessage = jQuery(this.htmlErrorMessage);
		this.textMarks = [];
		this.textSuggestions = [];
		this.instance.pegeditor = this;
	}

	addTextMark(textMark) {
		this.textMarks.push(textMark);
	}

	clearErrorMessage() {
		this.jErrorMessage.removeClass("active").find(".MessageBox").text("");
	}

	clearTextMarks() {
		this.textMarks.forEach(textMark => {
			textMark.clear();
		});
		this.textMarks = [];
	}

	clearSuggestions() {
		this.jErrorMessage.find(".SuggestionsBox").html("");
		this.textSuggestions = [];
	}

	setError(error) {
		if(typeof error === "object" && typeof error.location === "object" && typeof error.location.start === "object") {
			const doc = this.instance.getDoc();
			const startPoint = error.location.start;
			const endPoint = error.location.end;
			const textMark = doc.markText({line:startPoint.line-1,ch:startPoint.column-1}, {line:endPoint.line-1,ch:endPoint.column-1}, {className: "pegeditor-error"});
			this.textMarks.push(textMark);
			console.log(error);
			if(typeof error.expected === "object") {
				this.addSuggestions(error.expected, error);
			}
		}
		this.setErrorMessage(error);	
	}

	setErrorMessage(message) {
		this.jErrorMessage.addClass("active").find(".MessageBox").text(message);
	}

	clearError() {
		this.clearErrorMessage();
		this.clearTextMarks();
		this.clearSuggestions();
	}

	addSuggestions(suggestions, error) {
		this.clearSuggestions();
		this.textSuggestions = suggestions;
		const suggestionsBox = this.jErrorMessage.find(".SuggestionsBox");
		const allLiterals = [];
		//suggestionsBox.append("<div class='LabelSuggestion'>Suggestions:</div>")
		this.textSuggestions.forEach(textSuggestion => {
			console.log(textSuggestion);
			switch(textSuggestion.type) {
				case "literal":
					this.createLiteralSuggestion(textSuggestion, error, suggestionsBox, allLiterals);
					break;
				default:
					break;
			}
		});
	}

	createLiteralSuggestion(suggestion, error, suggestionsBox, allLiterals = []) {
		const literal = (() => {
			const vData = suggestion.text ? suggestion.text : suggestion.value ? suggestion.value : undefined;
			const v = JSON.stringify(vData);
			const vLabel = v.startsWith('"') && v.endsWith('"') && !(/^\"[\t\r\n ]*\"$/g).test(v) ? v.replace(/^\"|\"$/g,"") : v;
			if(v === '""' || v === "" || typeof v !== "string") {
				return undefined;
			}
			return {value:vData,stringify:v,label:vLabel};
		})();
		if(!literal) return;
		if(allLiterals.indexOf(literal.stringify) !== -1) return;
		allLiterals.push(literal.stringify);
		const htmlLiteralSuggestion = (() => {
			return jQuery("<div class='ErrorSuggestion'>")
				.data("pegeditor-value", literal.value)
				.data("pegeditor-string", literal.stringify)
				.data("pegeditor-error", JSON.stringify(error))
				.data("pegeditor-suggestion", JSON.stringify(suggestion))
				.text(literal.label);
		})();
		if(htmlLiteralSuggestion) {
			suggestionsBox.append(htmlLiteralSuggestion);
		}
	}

	createOnChangeEvent(options = {}) {
		return (codemirrorInstance, selectedText) => {
			const value = codemirrorInstance.getValue();
			try {
				let parse = (typeof this.grammar === "function") ? this.grammar : jQuery.pegeditorGrammars[this.grammar];
				if(typeof parse !== "function") {
					console.log("Invalidated grammar: ", this.grammar);
					parse = s => s;
				}
				const output = parse(value, options.parseOptions || {});
				this.lastValidOutput = output;
				this.clearError();
				if(typeof options.onSuccess === "function") {
					options.onSuccess(output, options, this, this.instance, value);
				}
				return output;
			} catch(error) {
				this.clearError();
				this.setError(error);
				if(typeof options.onError === "function") {
					options.onError(error, options, this, this.instance, value);
				}
				throw error;
			}
		};
	}

}

jQuery.PegEditor = PegEditor;
jQuery.pegeditorGrammars = {};
jQuery.registerPegeditorGrammar = function(name, grammar) {
	jQuery.pegeditorGrammars[name] = grammar;
};

jQuery.registerPegeditorCallback = function(name, callback) {
	if(typeof jQuery.pegeditorCallbacks !== "object") {
		jQuery.pegeditorCallbacks = {};
	}
	jQuery.pegeditorCallbacks[name] = callback;
};

jQuery.fn.pegeditor = function(options = {}) {

	const createEditor = (originalElement, options) => {
		return new PegEditor(originalElement, options);
	};

	const assignEvents = (editor, options) => {
		editor.instance.on("change", editor.createOnChangeEvent(options));
		jQuery(editor.instance.getWrapperElement()).on("click", ".ErrorSuggestion", () => {
			const text = editor.instance.getValue();
			const jThis = jQuery(event.target);
			const literalString = jThis.data("pegeditor-string");
			const literalValue = jThis.data("pegeditor-value");
			const literalErrorJson = jThis.data("pegeditor-error");
			const literalError = JSON.parse(literalErrorJson);
			const finalText = text.slice(0, literalError.location.start.offset) + literalValue + text.slice(literalError.location.start.offset);
			console.log("click",literalString,literalValue,finalText,jThis);
			editor.instance.setValue(finalText);
			editor.instance.setCursor({line: literalError.location.start.line, ch: literalError.location.start.column + literalString.length})
			editor.instance.focus();
		});
	};

	const validateEditor = (editor, options) => {
		if(typeof editor.grammar !== "function") {
			if(typeof editor.grammar === "string") {
				if(editor.grammar in jQuery.pegeditorGrammars) {
					
				} else throw new Error("[data-pegeditor-grammar] must be an existing jQuery.pegeditorGrammars property, but <" + editor.grammar + "> was not found in: <" + Object.keys(jQuery.pegeditorGrammars).join(", ") + ">")
			} else throw new Error("[data-pegeditor-grammar] must be an existing jQuery.pegeditorGrammars property, but <" + editor.grammar + "> was not found in: <" + Object.keys(jQuery.pegeditorGrammars).join(", ") + ">")
		}
	}

	this.each(function() {
		const editor = createEditor(this, options);
		validateEditor(editor, options);
		assignEvents(editor, options);
		// This is the editors global registry:
		if(typeof options.onInitialized === "function") {
			options.onInitialized(editor, options);
		}
		window.pegeditors[editor.id] = editor;
	});


	return this;
};