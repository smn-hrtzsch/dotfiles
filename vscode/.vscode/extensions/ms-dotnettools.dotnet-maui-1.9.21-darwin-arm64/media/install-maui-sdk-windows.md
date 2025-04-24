## Install the .NET MAUI SDK

If you do not have __.NET MAUI SDK__ installed on your machine, you can install it through the __Visual Studio Installer__ (preferred method) or by clicking on [Install .NET MAUI SDK](command:vscode-maui.installMauiSdk).

To verify it's installed, [open a terminal](command:workbench.action.terminal.new) and try running the following command:

```
dotnet workload list
```

You should see the `maui` workload ID listed alongside the installed version. But, if you have installed it through the Visual Studio Installer the following workload IDs are listed:

```
android
maui-windows
maccatalyst
ios
```

For more information, [see the online documentation](command:vscode-maui.configure).