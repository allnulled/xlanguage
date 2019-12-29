const path = require("path");
const chokidar = require("chokidar");
const importFresh = require("import-fresh");
const exec = require("execute-command-sync");
const parserSourceFile = path.resolve(__dirname + "/../src/lib/mylanguage.parser.pegjs");
const eventFunc = (event, path) => {
	console.log(event, path);
	importFresh(__dirname + "/build-parser.js");
};
chokidar.watch(parserSourceFile).on("change", eventFunc);
