# Change Log

## Current Stable version (1.9.x)

### Fixed
- JDK version recommendation fallback updated (only needed for extremely rare new installations with MAUI workload configuration issues)
- [[Bug] Android fails to load if latest cmdline-tools is installed among other versions](https://github.com/microsoft/vscode-dotnettools/issues/1765)
- [Bug] Debug console information shows enabled status when Just My Code option is disabled in Windows platform AzDO#1940770

### Added
- Use .NET 9 as the default runtime and target framework

## 1.9.19 - Prerelease

### Fixed
- JDK version recommendation fallback updated (only needed for extremely rare new installations with MAUI workload configuration issues)

## Current Prerelease version (1.9.15)

### Fixed
- [[Bug] Android fails to load if latest cmdline-tools is installed among other versions](https://github.com/microsoft/vscode-dotnettools/issues/1765)

### Added
- Use .NET 9 as the default runtime and target framework

## 1.9.6 - Prerelease

### Fixed
- [Bug] Debug console information shows enabled status when Just My Code option is disabled in Windows platform AzDO#1940770

## 1.8.7 - Release

### Fixed
- [BUG] VSCode extension suggests using JDK 17 or later, rather than just 17.0.12 AzDO#2332864

## 1.8.5 - Prerelease

### Fixed
- [BUG] VSCode extension suggests using JDK 17 or later, rather than just 17.0.12 AzDO#2332864

## 1.7.12 - Release

### Fixed
- [BUG] "No launchable projects found" error occurs when clicking the C# Startup Project or Launch Configuration button in Android Application after enabling the Launch Experience setting on MACOS AzDO#2325359
- [[Bug] iOS Extension project deploys on iOS simulator instead of iOS App](https://github.com/microsoft/vscode-dotnettools/issues/548)

### Added
- Removed the **Use VSDbg** setting. The new debugger will be used by default when using dotnet SDK 8.0.202 or above and targeting net8.0 or above

## 1.7.10 - Prerelease

### Fixed
- [BUG] "No launchable projects found" error occurs when clicking the C# Startup Project or Launch Configuration button in Android Application after enabling the Launch Experience setting on MACOS AzDO#2325359
- [[Bug] iOS Extension project deploys on iOS simulator instead of iOS App](https://github.com/microsoft/vscode-dotnettools/issues/548)

## 1.7.3 - Prerelease

### Added
- Removed the **Use VSDbg** setting. The new debugger will be used by default when using dotnet SDK 8.0.202 or above and targeting net8.0 or above

## 1.6.16 - Release

### Fixed
- Ensures startup project is set before selecting debug target.

## 1.6.14 - Prerelease

### Fixed
- Ensures startup project is set before selecting debug target.

## 1.5.34 - Release

### Added
- Added support for [xcsync](https://github.com/dotnet/xcsync) in the command palette under `.NET MAUI: xcsync- Generate an Xcode project` and `.NET MAUI: xcsync- Sync from an Xcode project`
- Improved Android initialization with the AndroidSDK and JavaSDK detected by Workload
- Improves Android environment report and user guidance.

### Fixed
- [BUG] .NET MAUI Pick Startup Project command failed AzDO#2298274
- [BUG] Incomplete Android environment detection without having a startup project AzDO#2255039
- [BUG] After creating an AVD from terminal, the environment check detects it, but launch profiles do not display the new AVD AzDO#2296063
- [BUG] When removing some Android related components and opening an existing project that was debugged earlier, a debugging canceled error will appear AzDO#2285217
- [[BUG] x ndk-bundle: not installed](https://github.com/microsoft/vscode-dotnettools/issues/1534)
- [[BUG] MAUI Extension fails to find Android SDK](https://github.com/microsoft/vscode-dotnettools/issues/717)
- [BUG] Setting Android SDK path via MSBuild properties in .csproj file does not work AzDO#2244608
- [[BUG] No launchable projects found with new launch experience](https://github.com/microsoft/vscode-dotnettools/issues/1439)
- [BUG] When Launch Experience is enabled, the Launch Configuration and Startup project Quick Pick List cannot be opened on Mac and Linux, the project cannot load completely on Windows AzDO#2275331
- [Keeps repeating asking for a startup project](https://github.com/microsoft/vscode-dotnettools/issues/1464)
- [BUG] MAUI extension picks any unsupported OpenJDK instead of erroring out when no supported version is installed AzDO2227588

## 1.5.32 - Prerelease

### Fixed
- [BUG] .NET MAUI Pick Startup Project command failed AzDO#2298274

## 1.5.29 - Prerelease

### Fixed
- [BUG] Incomplete Android environment detection without having a startup project AzDO#2255039
- [BUG] After creating an AVD from terminal, the environment check detects it, but launch profiles do not display the new AVD AzDO#2296063

### Added
- Added support for [xcsync](https://github.com/dotnet/xcsync) in the command palette under `.NET MAUI: xcsync- Generate an Xcode project` and `.NET MAUI: xcsync- Sync from an Xcode project`

## 1.5.19 - Prerelease

### Fixed
- [BUG] When removing some Android related components and opening an existing project that was debugged earlier, a debugging canceled error will appear AzDO#2285217
- [[BUG] x ndk-bundle: not installed](https://github.com/microsoft/vscode-dotnettools/issues/1534)

### Added
- Improved Android initialization with the AndroidSDK and JavaSDK detected by Workload

## 1.5.12 - Prerelease

### Fixed
- [[BUG] MAUI Extension fails to find Android SDK](https://github.com/microsoft/vscode-dotnettools/issues/717)
- [BUG] Setting Android SDK path via MSBuild properties in .csproj file does not work AzDO#2244608
- [[BUG] No launchable projects found with new launch experience](https://github.com/microsoft/vscode-dotnettools/issues/1439)
- [BUG] When Launch Experience is enabled, the Launch Configuration and Startup project Quick Pick List cannot be opened on Mac and Linux, the project cannot load completely on Windows AzDO#2275331
- [Keeps repeating asking for a startup project](https://github.com/microsoft/vscode-dotnettools/issues/1464)
- [BUG] MAUI extension picks any unsupported OpenJDK instead of erroring out when no supported version is installed AzDO2227588

### Added
- Improves Android environment report and user guidance.

## 1.4.36 - Release

### Fixed
- [BUG] Deploying an iOS app to physical device leaves zombie processes AzDO#2263034
- Improved detection of Android prerequisites after loading a MAUI project
- Partial fix for [[BUG] Randomly unable to debug MAUI project](https://github.com/microsoft/vscode-dotnettools/issues/1449)
  Now the app launch works on macOS Sequoia and you are able to debug, but XAML Hot Reload won't function, due to [an issue](https://github.com/dotnet/runtime/issues/106775)
  in the .NET runtime on Sequoia. A complete fix will be available once the VS Code C# extension takes an updated .NET runtime
  with this fixed. See [bug link](https://github.com/microsoft/vscode-dotnettools/issues/1449) for details and workarounds to use XAML Hot Reload in the meantime on Sequoia.

## 1.4.34 - Prerelease

### Fixed
- [BUG] Deploying an iOS app to physical device leaves zombie processes AzDO#2263034
- Improved detection of Android prerequisites after loading a MAUI project
- Partial fix for [[BUG] Randomly unable to debug MAUI project](https://github.com/microsoft/vscode-dotnettools/issues/1449)
  Now the app launch works on macOS Sequoia and you are able to debug, but XAML Hot Reload won't function, due to [an issue](https://github.com/dotnet/runtime/issues/106775)
  in the .NET runtime on Sequoia. A complete fix will be available once the VS Code C# extension takes an updated .NET runtime
  with this fixed. See [bug link](https://github.com/microsoft/vscode-dotnettools/issues/1449) for details and workarounds to use XAML Hot Reload in the meantime on Sequoia.

## 1.3.29 - Release

### Fixed
- [[BUG] 1.10.12 broke .NET and the editor just gets stuck loading](https://github.com/microsoft/vscode-dotnettools/issues/1407)
- (Preview) Add support for the C# Dev Kit Improved Launch/Debug Experience
- [BUG] After reopening the multi-project solution, the status bar always shows 'project' progress AzDo#2239605

## 1.3.26 - Prerelease

### Fixed
- [BUG] After reopening the multi-project solution, the status bar always shows 'project' progress AzDo#2239605

## 1.3.24 - Prerelease

### Fixed
- [[BUG] 1.10.12 broke .NET and the editor just gets stuck loading](https://github.com/microsoft/vscode-dotnettools/issues/1407)
- (Preview) Add support for the C# Dev Kit Improved Launch/Debug Experience

## 1.3.3 - Prerelease

### Fixed
- Fixes and improvements

## 1.2.15 - Release

### Fixed
- [BUG] Android license acceptance manual instructions can be improved with JAVA_HOME required path AzDo#2174751
- [[BUG] Maui extension won't load after fresh install](https://github.com/microsoft/vscode-dotnettools/issues/1203)

## 1.2.12 - Prerelease

### Fixed
- [BUG] Android license acceptance manual instructions can be improved with JAVA_HOME required path AzDo#2174751

## 1.2.5 - Prerelease

### Fixed
- Fixes and improvements

## 1.2.3 - Prerelease

### Fixed
- [[BUG] Maui extension won't load after fresh install](https://github.com/microsoft/vscode-dotnettools/issues/1203)

## 1.1.16 - Release

### Fixed
- [BUG] C#/MAUI extension doesn't correctly match MSBuild errors to show them in the Problems panel AzDo#2073500

## 1.1.14 - Prerelease

### Fixed
- Fixes and improvements

## 1.1.8 - Prerelease

### Fixed
- [BUG] C#/MAUI extension doesn't correctly match MSBuild errors to show them in the Problems panel AzDo#2073500

## 1.1.6 - Prerelease

### Fixed
- Fixes and improvements

## 1.0.6 - Release

### Fixed
- Apple SDK information no longer refreshes on every .csproj edit
- Walkthrough improvements
- [BUG] MAUI getting started "Set up your .NET MAUI environment" step has a few issues AzDo#2051921
- [BUG] Confusing MAUI workload install instructions AzDo#2055574

### Added
- The first iterations of XAML and C# Hot Reload are now available in the .NET MAUI extension. XAML Hot Reload is on by
  default - to use it, just change your XAML while the app is running! All platforms are supported.
  To enable C# Hot Reload, in **Preferences: Open User Settings** search for **Hot Reload** and check **[Experimental] Enables Hot Reload while debugging**. Click the "Fire" icon in the debug toolbar while the app is running to
  apply code changes. C# Hot Reload with Android and WinUI should work, but iOS/Catalyst aren't yet supported.
- Support C# DevKit solution configurations AzDo#2054729

## 0.12.42 - Prerelease

### Fixed
- Fixes and improvements

## 0.12.40 - Prerelease

### Added
- Removed "Preview" designation from XAML Hot Reload, as it becomes a released feature.

## 0.12.24 - Prerelease

### Added
- Preview support for XAML Hot Reload. It's on by default, but can be disabled if desired via the "Enables XAML Hot Reload while debugging" user
  preference setting. iOS physical devices aren't yet supported, but iOS simulator, Catalyst, Android, and WinUI should all work
- Support C# DevKit solution configurations AzDo#2054729

### Fixed
- Apple SDK information no longer refreshes on every .csproj edit

## 0.12.17 - Prerelease

### Fixed
- Walkthrough improvements
- [BUG] MAUI getting started "Set up your .NET MAUI environment" step has a few issues AzDo#2051921
- [BUG] Confusing MAUI workload install instructions AzDo#2055574

## 0.11.96 - Release

### Added
- Visual indicator for .NET MAUI SDK|Android SDK|Xcode detection errors
- `Set Xcode path` to the command palette, under `.NET MAUI: Configure Apple`
- Target .NET MAUI to net8 and ensure a net8 compatible runtime is always used to launch child processes AzDo#1985700

### Fixed
- [BUG] Deploy to iOS and MacCatalyst will automatically stop when VSDbg is checked AzDo#2053809
- [BUG] Debugger is not enabled for xaml files AzDo#2055584
- [BUG] AppleSDK state's Tooltip text not displaying when errored AzDo#1923388
- [BUG] Cannot change Xcode path if it is set in the VS/Mac shared settings AzDo#2047805
- [BUG] Press F5 when the status bar has projects progress a notification box will appear AzDo#2049223
- [BUG] .NET 9 MAUI project cannot be debugged on Android emulator AzDo#2014643
- [BUG] "Errors exist after running preLaunchTask 'maui:Build'." doesn't point to actual error AzDo#1829267
- [BUG] Adds Xcode recovery suggestion on .NET MAUI output window when Xcode device detection failed AzDo#2036691
- [BUG] The .NET MAUI output window does not display information at the top line when loading a project and pressing F5 AzDo#2033058
- [BUG] The Debug target is displayed incorrectly when switching to 'Build Only' debug target AzDo#2045717
- [BUG] Unable to open the drop-down list of startup project and debug target after switching between them multiple times AzDo#1948748
- [[BUG] Console.WriteLine Output does not appear in Debug Console](https://github.com/microsoft/vscode-dotnettools/issues/685)
- [BUG] Crashes/errors (logcat) from an Android app do not appear in the debug output AzDo#1845539
- [BUG] When Android emulator is closed the debug session is not stopped AzDo#2034215
- [BUG] MAUI Dev Kit enters in debug mode even if the iOS deployment/launch failed AzDo#1925344
- [[BUG] Please update your Apple SDK location in Visual Studio's preferences (Projects > SDK Locations > Apple > Apple SDK)](https://github.com/microsoft/vscode-dotnettools/issues/730)
- [BUG] The .NET MAUI output window does not display information at the top line AzDo#1994234
- [BUG] JDWP forward port is not removed when debug ends AzDo#2010777
- [BUG] The application doesn't exit when setting a breakpoint on InitializeComponent and stop debugging with android emulator AzDo#2012403
- [BUG] .Net Android Project does not select debug target on Mac after project load  AzDo#2019154
- [BUG] The value of the useVSDbg attribute is false in .NET MAUI output pane when the debug target is 'build only' AzDo#2020839
- Added support for 'ForceSimulatorX64ArchitectureInIDE' msbuild property to override 'RuntimeIdentifier' on Debug. [[BUG] clang++ exited with code 1](https://github.com/microsoft/vscode-dotnettools/issues/744)
- [BUG] The value of the useVSDbg attribute is false in .NET MAUI - Telemetry window when Xcode not present AzDo#2012387
- [BUG] Remove Debug Server Port user preference setting as it's internal only AzDo#2015133

## 0.11.94 - Prerelease

### Fixed
- [BUG] Deploy to iOS and MacCatalyst will automatically stop when VSDbg is checked AzDo#2053809
- [BUG] Debugger is not enabled for xaml files AzDo#2055584

## 0.11.87 - Prerelease

### Added
- Visual indicator for .NET MAUI SDK|Android SDK|Xcode detection errors
- `Set Xcode path` to the command palette, under `.NET MAUI: Configure Apple`

### Fixed
- [BUG] AppleSDK state's Tooltip text not displaying when errored AzDo#1923388
- [BUG] Cannot change Xcode path if it is set in the VS/Mac shared settings AzDo#2047805
- [BUG] Press F5 when the status bar has projects progress a notification box will appear AzDo#2049223
- [BUG] .NET 9 MAUI project cannot be debugged on Android emulator AzDo#2014643

## 0.11.57 - Prerelease

### Added
- Target .NET MAUI to net8 and ensure a net8 compatible runtime is always used to launch child processes AzDo#1985700

### Fixed
- [BUG] "Errors exist after running preLaunchTask 'maui:Build'." doesn't point to actual error AzDo#1829267
- [BUG] Adds Xcode recovery suggestion on .NET MAUI output window when Xcode device detection failed AzDo#2036691
- [BUG] The .NET MAUI output window does not display information at the top line when loading a project and pressing F5 AzDo#2033058
- [BUG] The Debug target is displayed incorrectly when switching to 'Build Only' debug target AzDo#2045717
- [BUG] Unable to open the drop-down list of startup project and debug target after switching between them multiple times AzDo#1948748

## 0.11.34 - Prerelease

### Fixed
- [[BUG] Console.WriteLine Output does not appear in Debug Console](https://github.com/microsoft/vscode-dotnettools/issues/685)
- [BUG] Crashes/errors (logcat) from an Android app do not appear in the debug output AzDo#1845539
- [BUG] When Android emulator is closed the debug session is not stopped AzDo#2034215
- [BUG] MAUI Dev Kit enters in debug mode even if the iOS deployment/launch failed AzDo#1925344

## 0.11.16 - Prerelease

### Fixed
- [[BUG] Please update your Apple SDK location in Visual Studio's preferences (Projects > SDK Locations > Apple > Apple SDK)](https://github.com/microsoft/vscode-dotnettools/issues/730)
- [BUG] The .NET MAUI output window does not display information at the top line AzDo#1994234
- [BUG] JDWP forward port is not removed when debug ends AzDo#2010777
- [BUG] The application doesn't exit when setting a breakpoint on InitializeComponent and stop debugging with android emulator AzDo#2012403
- [BUG] .Net Android Project does not select debug target on Mac after project load  AzDo#2019154
- [BUG] The value of the useVSDbg attribute is false in .NET MAUI output pane when the debug target is 'build only' AzDo#2020839

## 0.11.3 - Prerelease

### Fixed
- Added support for 'ForceSimulatorX64ArchitectureInIDE' msbuild property to override 'RuntimeIdentifier' on Debug. [[BUG] clang++ exited with code 1](https://github.com/microsoft/vscode-dotnettools/issues/744)
- [BUG] The value of the useVSDbg attribute is false in .NET MAUI - Telemetry window when Xcode not present AzDo#2012387
- [BUG] Remove Debug Server Port user preference setting as it's internal only AzDo#2015133

## 0.10.61 - Release

### Added
- Adds progress bar indicator for Android Emulator launch process AzDo#2005160
- Telemetry improvements AzDo#2005576
- Telemetry improvements AzDo#1994389
- **.NET Core Debugger backend (vsdbg) support for MAUI apps** (Added support for debugging MAUI apps with the .NET Core Debugger backend (vsdbg) for .NET 8.0.202 or above. To enable/disable this feature, use the maui.configuration.experimental.useVSDbg setting. The setting will be enabled by default if the .NET requirements are met)

### Fixed
- [BUG] Use VSDbg displays 1 instead of true in the .NET MAUI output pane AzDo#1974722
- [[BUG] non-MAUI .NET Debug launch hangs with when the pre-release .NET MAUI extension is installed](https://github.com/microsoft/vscode-dotnettools/issues/1012)
- Improves Xcode detection AzDo#1993200
- [BUG] Support detection of Android Sdk component cmdline-tools when the version installed is 'latest'. Fixes [.NET Maui Command Line Tools Not Installed](https://github.com/microsoft/vscode-dotnettools/issues/842)
- [BUG] Android platform cannot find JDK if it is installed in ProgramFilesX86 AzDo#1987640
- [BUG] "Create new Emulator" debug target opens learn more page to guide user to creates an AVD AzDo#1843555
- [BUG] The target drop-down list does not highlight the currently selected Startup project AzDo#1948719
- [BUG] Remove Android SDK recommended required platforms-tools components: Information printed twice in .NET MAUI output AzDo#1991565
- [BUG] The Xcode location should also consider the Settings.plist file AzDo#1934962

## 0.10.59 - Prerelease

### Added
- Adds progress bar indicator for Android Emulator launch process AzDo#2005160
- Telemetry improvements AzDo#2005576

## 0.10.50 - Prerelease

### Added
- Telemetry improvements AzDo#1994389

### Fixed
- [BUG] Use VSDbg displays 1 instead of true in the .NET MAUI output pane AzDo#1974722
- [[BUG] non-MAUI .NET Debug launch hangs with when the pre-release .NET MAUI extension is installed](https://github.com/microsoft/vscode-dotnettools/issues/1012)

## 0.10.30 - Prerelease

### Added
- **.NET Core Debugger backend (vsdbg) support for MAUI apps** (Added support for debugging MAUI apps with the .NET Core Debugger backend (vsdbg) for .NET 8.0.202 or above. To enable/disable this feature, use the maui.configuration.experimental.useVSDbg setting. The setting will be enabled by default if the .NET requirements are met)

### Fixed
- Improves Xcode detection AzDo#1993200

## 0.10.16 - Prerelease

### Fixed
- Fixes and improvements

## 0.10.14 - Prerelease

### Fixed
- Fixes and improvements

## 0.10.10 - Prerelease

### Fixed
- [BUG] Support detection of Android Sdk component cmdline-tools when the version installed is 'latest'. Fixes [.NET Maui Command Line Tools Not Installed](https://github.com/microsoft/vscode-dotnettools/issues/842)
- [BUG] Android platform cannot find JDK if it is installed in ProgramFilesX86 AzDo#1987640
- [BUG] "Create new Emulator" debug target opens learn more page to guide user to creates an AVD AzDo#1843555
- [BUG] The target drop-down list does not highlight the currently selected Startup project AzDo#1948719
- [BUG] Remove Android SDK recommended required platforms-tools components: Information printed twice in .NET MAUI output AzDo#1991565
- [BUG] The Xcode location should also consider the Settings.plist file AzDo#1934962

## 0.9.7 - Release

### Fixed
- Fixes and improvements

## 0.9.5 - Release

### Fixed
- [BUG] Xcode not found if using different path from `Xcode.app`

## 0.9.3 - Prerelease

### Fixed
- [BUG] Xcode not found if using different path from `Xcode.app`

## 0.8.44 - Release

### Fixed
- Custom configuration does not hit breakpoints on Android. Fixes [Breakpoints do not work when debugging configuration other than Debug](https://github.com/dotnet/maui/issues/20132)
- [BUG] The debug target list and the debug target display are inconsistent AzDo#1948725
- [BUG] Telemetry improvements AzDo#1909215
- Only iOS simulators that were running on extension load display as "running". Fixes [MAUI ios device picker lists all simulators as 'running'](https://github.com/microsoft/vscode-dotnettools/issues/677)
- [BUG] iOS physical devices are not dynamically discovered AzDo#1923989
- Added support for overriding `RuntimeIdentifier` from project file. Fixes [[BUG] clang++ exited with code 1 #744](https://github.com/microsoft/vscode-dotnettools/issues/744).

## 0.8.42 - Prerelease

### Fixed
- Custom configuration does not hit breakpoints on Android. Fixes [Breakpoints do not work when debugging configuration other than Debug](https://github.com/dotnet/maui/issues/20132)
- [BUG] The debug target list and the debug target display are inconsistent AzDo#1948725
- [BUG] Telemetry improvements AzDo#1909215

## v0.8.30 - Prerelease

### Fixed
- Only iOS simulators that were running on extension load display as "running". Fixes [MAUI ios device picker lists all simulators as 'running'](https://github.com/microsoft/vscode-dotnettools/issues/677)
- [BUG] iOS physical devices are not dynamically discovered AzDo#1923989

## v0.8.3 - Prerelease

### Fixed
- Added support for overriding `RuntimeIdentifier` from project file. Fixes [[BUG] clang++ exited with code 1 #744](https://github.com/microsoft/vscode-dotnettools/issues/744).

## v0.7.10 - Release

### Fixed
- Fixes and improvements

## v0.7.8 - Prerelease

### Fixed
- Version bump to 0.7.*

## v0.6.54 - Release

### Fixed
- Duplicate "Debugging canceled" messages are printed when starting debugging with a machine that is not configured with the Android SDK AzDo#1910140
- default debug target is not set when startup project changed AzDo#1908556
- [[BUG] ".NET MAUI SDK not found" error with VS Code if folder contains more than one file with an extension ending with 'proj' #654](https://github.com/microsoft/vscode-dotnettools/issues/654)
- [[BUG] Debugging canceled: MAUI SDK not found](https://github.com/microsoft/vscode-dotnettools/issues/523)

## v0.6.52 - Prerelease

### Fixed
- Unavailable iOS devices will no longer be listed when extension loads AzDo#1923376
- Using XCode without accepting licenses displays an error and shows guidance on how to resolve it AzDo#1912961

## v0.6.19 - Prerelease

### Fixed
- Bug fixes

## v0.6.6 - Prerelease

### Fixed
- Duplicate "Debugging canceled" messages are printed when starting debugging with a machine that is not configured with the Android SDK AzDo#1910140
- default debug target is not set when startup project changed AzDo#1908556
- [[BUG] ".NET MAUI SDK not found" error with VS Code if folder contains more than one file with an extension ending with 'proj' #654](https://github.com/microsoft/vscode-dotnettools/issues/654)
- [[BUG] Debugging canceled: MAUI SDK not found](https://github.com/microsoft/vscode-dotnettools/issues/523)

## v0.5.50 - Release

### Fixed
- [Android updates message could be more helpful #272](https://github.com/microsoft/vscode-dotnettools/issues/272)
- Unconfigured Android SDK/JDK causes confusion over not accepted licenses AzDo#1848378
- Building MAUI apps "out of the box" for Android fails due to AP lv 34 missing AzDo#1896303
- No MAUI app project warning if pressing F5 while loading project AzDo#1843657
- The .NET MAUI output window message only prompts the Android component list when optional components are removed AzDo#1907802
- Adds .NET MAUI output verbosity settings AzDo#1823394
- Avoids project load failure when project target not supported platforms
- [The Preferred Android SDK/Java SDK directory was not used. But WHY? [Found the problem]](https://github.com/microsoft/vscode-dotnettools/issues/561)
- Improves Android Licenses help

## v0.5.48 - Prerelease

### Fixed
- [Android updates message could be more helpful #272](https://github.com/microsoft/vscode-dotnettools/issues/272)
- Unconfigured Android SDK/JDK causes confusion over not accepted licenses AzDo#1848378
- Building MAUI apps "out of the box" for Android fails due to AP lv 34 missing AzDo#1896303
- No MAUI app project warning if pressing F5 while loading project AzDo#1843657
- The .NET MAUI output window message only prompts the Android component list when optional components are removed AzDo#1907802

## v0.5.32 - Prerelease

### Fixed
- Adds .NET MAUI output verbosity settings AzDo#1823394
- Avoids project load failure when project target not supported platforms
- [The Preferred Android SDK/Java SDK directory was not used. But WHY? [Found the problem]](https://github.com/microsoft/vscode-dotnettools/issues/561)
- Improves Android Licenses help

## v0.5.3 - Prerelease

### Fixed
- Bug fixes

## v0.4.9 - Release

### Fixed
- .NET Maui: Pick Android Device does not show usb devices. AzDo#1864430
- No devices found before restarting VS Code on Linux AzDo#1872355
- [[BUG] Solution Explorer -> Build shows unnecessary "Type to Filter Project" box #515](https://github.com/microsoft/vscode-dotnettools/issues/515)
- The .NET 8.0 ios/maccatalyst app cannot debug on a machine without .NET 7.0 installed AzDo#1879753
- .NET 8.0 MAUI project cannot be debugged AzDo#1852343
- [Android Licensing dialog box - slashes are going in the wrong direction #468](https://github.com/microsoft/vscode-dotnettools/issues/468)
- [.NET MAUI Extension: The preferred Android SDK/Java SDK directory was not used. #510](https://github.com/microsoft/vscode-dotnettools/issues/510)
- [Debugging canceled: MAUI SDK not found. #523](https://github.com/microsoft/vscode-dotnettools/issues/523)
- Microsoft OpenJDK 17

## v0.4.5 - Prerelease

### Fixed
- .NET Maui: Pick Android Device does not show usb devices. AzDo#1864430
- No devices found before restarting VS Code on Linux. AzDo#1872355

## v0.4.4 - Prerelease

### Fixed
- [[BUG] Solution Explorer -> Build shows unnecessary "Type to Filter Project" box #515](https://github.com/microsoft/vscode-dotnettools/issues/515)
- The .NET 8.0 ios/maccatalyst app cannot debug on a machine without .NET 7.0 installed AzDo#1879753
- .NET 8.0 MAUI project cannot be debugged AzDo#1852343
- [Android Licensing dialog box - slashes are going in the wrong direction #468](https://github.com/microsoft/vscode-dotnettools/issues/468)
- [.NET MAUI Extension: The preferred Android SDK/Java SDK directory was not used.](https://github.com/microsoft/vscode-dotnettools/issues/510)
- [Debugging canceled: MAUI SDK not found.](https://github.com/microsoft/vscode-dotnettools/issues/523)
- Microsoft OpenJDK 17

## v0.3.22 - Release

### Fixed
- .NET MAUI SDK not found on .NET 8.0.100-preview.7.23376.3 AzDo#1870972
- NRE happens when JAVA SDK is not installed AzDo#1867881
- [[BUG] NET MAUI SDK: not found #269](https://github.com/microsoft/vscode-dotnettools/issues/269)

## v0.3.1 - Prerelease

### Fixed
- [[BUG] NET MAUI SDK: not found #269](https://github.com/microsoft/vscode-dotnettools/issues/269)

## v0.2.12 - Release

### Fixed
- The restart button does not work correctly AzDo#1835871
- Android: error displayed when Debugger breaks on unhandled exceptions AzDo#1836830
- [[BUG] Breakpoints not hit on MAUI Blazor on Mac #292](https://github.com/microsoft/vscode-dotnettools/issues/292)
- [[SUGGESTION] Some improvements for debugging MAUI #273](https://github.com/microsoft/vscode-dotnettools/issues/273)
- [[BUG] MAUI: Android license has to be accepted on every restart #249](https://github.com/microsoft/vscode-dotnettools/issues/249)

## v0.1.34 - Release

- Initial Release
