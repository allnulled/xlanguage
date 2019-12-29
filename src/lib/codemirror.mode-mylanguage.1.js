window.CodeMirror.defineSimpleMode("mylanguage", {
  // The start state contains the rules that are intially used
  start: [
    // The regex matches the token, the token property contains the type
    {
      regex: /\{[^\}]+\}/g,
      token: "fenomeno"
    },
    {
      regex: /\¿por qué |\¿|\?/g,
      token: "pregunta"
    },
    {
      regex: /\@[A-Za-z0-9_\-ÁÉÍÓÚáéíóúñäëïöüÄËÏÖÜàèìòùÀÈÌÒÙ]+/g,
      token: "adjetivo"
    },
    {
      regex: /\([^\)]+\)/g,
      token: "comentario"
    },
    {
      regex: / *\=+\> *[A-Za-z0-9_\-ÁÉÍÓÚáéíóúñäëïöüÄËÏÖÜàèìòùÀÈÌÒÙ]+\:?/g,
      token: "verbo"
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
