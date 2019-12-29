const configurations = {
	fileOrigin: __dirname + "/../src/lib/mylanguage.parser.pegjs",
	fileDestiny: __dirname + "/../src/lib/mylanguage.parser.js",
	forParser: {
		output: "source",
		format: "globals",
		exportVar: "MyLanguageParser = window.MyLanguageParser"
	}
};
const fs = require("fs");
const pegjs = require("pegjs");
try {
	const language_parser_contents = fs.readFileSync(configurations.fileOrigin).toString();
	const language_parser_contents_js = pegjs.generate(language_parser_contents, configurations.forParser);
	fs.writeFileSync(configurations.fileDestiny, language_parser_contents_js, "utf8");
} catch(error) {
	console.log("[*] ERROR:", error);
}