'use strict';
Object.defineProperty(exports, "__esModule", { value: true });
exports.deactivate = exports.activate = void 0;
// The module 'vscode' contains the VS Code extensibility API
// Import the module and reference it with the alias vscode in your code below
const vscode = require("vscode");
const child_process_1 = require("child_process");
const path_1 = require("path");
const util_1 = require("util");
// this method is called when your extension is activated
// your extension is activated the very first time the command is executed
function activate(context) {
    // Use the console to output diagnostic information (console.log) and errors (console.error)
    // This line of code will only be executed once when your extension is activated
    console.log('Congratulations, your extension "csharp-to-plantuml" is now active!');
    // The command has been defined in the package.json file
    // Now provide the implementation of the command with registerCommand
    // The commandId parameter must match the command field in package.json
    let disposable = vscode.commands.registerCommand('csharp2plantuml.classDiagram', () => {
        const wsroot = vscode.workspace.rootPath;
        if ((0, util_1.isUndefined)(wsroot)) {
            console.log("Open folder or workspace.");
            return;
        }
        const outputchannel = vscode.window.createOutputChannel("CSharp to PlantUML");
        const tool = (0, path_1.join)(context.extensionPath, 'lib', 'PlantUmlClassDiagramGenerator', 'PlantUmlClassDiagramGenerator.dll');
        const conf = vscode.workspace.getConfiguration();
        const inputPath = conf.get('csharp2plantuml.inputPath');
        const outputPath = conf.get('csharp2plantuml.outputPath');
        const publicOnly = conf.get('csharp2plantuml.public');
        const ignoreAccessibility = conf.get('csharp2plantuml.ignoreAccessibility');
        const excludePath = conf.get('csharp2plantuml.excludePath');
        const createAssociation = conf.get('csharp2plantuml.createAssociation');
        const allInOne = conf.get('csharp2plantuml.allInOne');
        const attributeRequired = conf.get('csharp2plantuml.attributeRequired');
        const excludeUmlBeginEndTags = conf.get('csharp2plantuml.excludeUmlBeginEndTags');
        const input = (0, path_1.join)(wsroot, inputPath);
        var command = `dotnet "${tool}" "${input}"`;
        if (outputPath !== "") {
            command += ` "${(0, path_1.join)(wsroot, outputPath)}"`;
        }
        command += " -dir";
        if (publicOnly) {
            command += " -public";
        }
        else if (ignoreAccessibility !== "") {
            command += ` -ignore "${ignoreAccessibility}"`;
        }
        if (excludePath !== "") {
            command += ` "${(0, path_1.join)(input, excludePath)}"`;
        }
        if (createAssociation) {
            command += " -createAssociation";
        }
        if (allInOne) {
            command += " -allInOne";
        }
        if (attributeRequired) {
            command += " -attributeRequired";
        }
        if (excludeUmlBeginEndTags) {
            command += " -excludeUmlBeginEndTags";
        }
        outputchannel.appendLine("[exec] " + command);
        (0, child_process_1.exec)(command, (error, stdout, stderror) => {
            outputchannel.appendLine(stdout);
            outputchannel.appendLine(stderror);
            if (error) {
                console.log(error);
            }
        });
    });
    context.subscriptions.push(disposable);
}
exports.activate = activate;
// this method is called when your extension is deactivated
function deactivate() { }
exports.deactivate = deactivate;
//# sourceMappingURL=extension.js.map