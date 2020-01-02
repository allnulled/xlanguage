window.CodeMirror.defineSimpleMode("mylanguage", {
  // The start state contains the rules that are intially used
  start: [
    // The regex matches the token, the token property contains the type
    {
      regex: /\{[^\}]+\}|\#[A-Za-z0-9ÁÉÍÓÚáéíóúÀÈÌÒÙàèìòùÑñ\-\_]+/g,
      token: "fenomeno"
    },
    {
      regex: /\¿qué |\¿por qué |\¿cómo |\¿cuándo |\¿dónde |\¿quién |\¿|\?/g,
      token: "pregunta"
    },
    {
      regex: /\@[A-Za-z0-9_\-ÁÉÍÓÚáéíóúñäëïöüÄËÏÖÜàèìòùÀÈÌÒÙ]+/g,
      token: "adjetivo"
    },
    {
      regex: /(\[\*[^\*]+\*\])/g,
      token: "comentario"
    },
    {
      regex: /\<\{|\}\>/g,
      token: "bloque"
    },
    {
      regex: / *\=+\> *[A-Za-z0-9_\-ÁÉÍÓÚáéíóúñäëïöüÄËÏÖÜàèìòùÀÈÌÒÙ]+\:?/g,
      token: "verbo"
    },
    {
      regex: /hay|hemos|habéis|han|he|has|ha|soy|eres|es|somos|sois|son|causamos|causáis|causan|causo|causas|causa|conllevamos|conlleváis|conllevan|conllevo|conllevas|conlleva|implicamos|implicáis|implican|implico|implicas|implica|significamos|significáis|significan|significo|significas|significa|posibilitamos|posibilitáis|posibilitan|posibilito|posibilitas|posibilita/g,
      token: "verbo-definido"
    },
    {
      regex: /determinaciones|determinación|indeterminaciones|indeterminación|determinados|determinadas|determinado|determinada|indeterminados|indeterminadas|indeterminado|indeterminada|verdad|falacia|cualquier cosa|cosa/g,
      token: "valor"
    },
  ],
  // The multi-line comment state.
  comment: [],
  // The meta property contains global information about the mode. It
  // can contain properties like lineComment, which are supported by
  // all modes, and also directives like dontIndentStates, which are
  // specific to simple modes.
  meta: {}
});

window.CodeMirror.defineSimpleMode("mylanguage-reporte", {
  // The start state contains the rules that are intially used
  start: [
    // The regex matches the token, the token property contains the type
    {
      regex: /^YO\:.+/g,
      token: "suceso"
    },
    {
      regex: /^PC\:.+/g,
      token: "negacion"
    },
  ],
  // The multi-line comment state.
  comment: [],
  // The meta property contains global information about the mode. It
  // can contain properties like lineComment, which are supported by
  // all modes, and also directives like dontIndentStates, which are
  // specific to simple modes.
  meta: {}
});
