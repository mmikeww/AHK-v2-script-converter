# AHK-v2-script-converter
Despite its name, this "Converter" functions more like an Assistant for migrating scripts from AHKv1 to [AHK v2](https://autohotkey.com/v2/) syntax. It's designed to automate the most tedious parts of the conversion process, but its scope is limited. While this tool may occasionally produce fully functional AHKv2 code, users should expect to make manual edits afterwards. Why not just use AI for the conversion? See [Tool vs AI](#tool-vs-ai).

Recommended process for conversion:
1. See [Usage 1](#usage-1-converter-user-interface) to open the Converter UI.
2. Set the Gui Conversion mode [Dynamic is recommended].
3. Press one of the three conversion buttons on the UI.
4. The tool should cover about 80%+ of the conversion process automatically.
5. Follow [Post Conversion](#post-conversion) guidelines for the remaining 20% (as necessary). 

[Contributions](#Contributing) to the project are also encouraged 

# Usage
## Usage 1 (Converter User Interface)
1. [Download](https://github.com/mmikeww/AHK-v2-script-converter/archive/master.zip) the full repo. Then run the included `Converter_UI.ahk` script with AHK v2
2. Conversion Settings:
   * $\color{magenta}\text{TAB1:}$ <span>[&#9881;]</span> Save all settings from other tabs [Manual/Auto]. Auto-save is recommended.
   * $\color{magenta}\text{GUI:}$ Provides several modes for Gui/GuiControl conversion. Also allows user to define the default GuiName and Control Prefix for v2 variable names [for Orig/Simple modes].
   * $\color{magenta}\text{HK:}$ Will eventually provide hotkey filtering to improve conversion performance.
   * $\color{magenta}\text{GENERAL:}$ Provides general conversion settings.
3. Set Gui Conversion Mode: [IMPORTANT]
   * $\color{magenta}\text{ORIG:}$ Provides Gui conversion using orig method. Being replaced by updated modes below.
   * $\color{magenta}\text{SIMPLE:}$ Updated version of Orig mode. Provides similar [but improved] result. Recommended for converting simple [non-dynamic] v1 Gui syntax.
   * $\color{magenta}\text{DYNAMIC:}$ [RECOMMENDED] Provides the best Gui conversion results, with limited support for dynamic attributes [within loops, func params, multiple scopes, ClassNN names, etc]. The catch? The v2 syntax is much different than other modes, and it requires an #include file [before/AFTER conversion].
   * $\color{magenta}\text{AUTO:}$ Analyzes the v1 source code and selects the 'best mode' automatically [Simple or Dynamic].
4. Conversion Buttons:
   * $\color{magenta}\text{Convert V1 Script File:}$ Runs v2converter to select/convert a script file. See Usage 2:3 below for more details.
   * $\color{magenta}\text{Convert V1 Code Fragment:}$ Runs QuickConvertorV2 for v1 code paste. See Usage 3:3 below. Paste v1 code fragment in left pane, convert using orange arrow button [bottom/center]. 
   * $\color{magenta}\text{Run QC Unit Tests:}$ Runs QuickConvertorV2 in Unit-Test Mode [for project contributors] - See Usage 3:7 below. Shift-Click this button to show failed unit-tests (also).



![screenshot](https://github.com/mmikeww/AHK-v2-script-converter/blob/master/images/Converter_UI.png)

## Usage 2 (Convert V1 Script File)
1. [Download](https://github.com/mmikeww/AHK-v2-script-converter/archive/master.zip) the full repo.
2. Run `Converter_UI.ahk`, then choose 'Convert v1 Script file' button. Or run `v2converter.ahk` directly.
3. Choose your input `scriptfile.ahk` written for AHK v1. The converted script will be named `scriptfile_newV2.ahk` in the same directory. Use `v2converter.ahk -h` in cmd to use the CLI.
   You can modify parts of how the script behave from editing variables inside the script
4. Look over the Visual Diff to manually inspect the changes
![screenshot](https://github.com/mmikeww/AHK-v2-script-converter/blob/master/images/screenshot.jpg)

## Usage 3 (Convert V1 Code Fragment, and Unit Testing)
1. [Download](https://github.com/mmikeww/AHK-v2-script-converter/archive/master.zip) the full repo.
2. Run `Converter_UI.ahk`, then choose 'Convert v1 Code' button. Or run `QuickConvertorV2.ahk` directly.
3. Select a string in another program and press XButton1 to convert it, or paste it in the first Edit and press the convert button (orange arrow).
4. When the cursor is on a function in the edit field, press F1 to search the function in the documentation.
5. You can run and close the V1 and V2 code with the play buttons.
6. There are also compare buttons to see better the difference between the scripts.
7. When working on ConvertFuncs.ahk, please set TestMode on in the Gui Menu Settings, in this mode, all the confirmed tests will be checked if the result stays the same. In this mode you can also save tests easily.
![screenshot](https://github.com/mmikeww/AHK-v2-script-converter/blob/master/images/Quick%20Convertor%20V2.png)

# Tool vs AI
This tool:
- Fast, consistent output. The tool been been pre-tested for common things that it supports.
- "Inspection comments" are added for things it does not support. It will not "invent" invalid code on the fly.
 
AI:
-  AI can provide invalid code (hallucinations), remove code, change logic flow, or get lost with lengthy scripts.
- There may also be token limits that prevents lengthy code from being accepted by AI.
- The back-and-forth with AI can be time-consuming, and new hallucinations are possible with each revision.

# Post conversion
Please understand that this tool is limited and may not produce fully functional AHKv2 code. Manual edits to the output should be expected. Use the tips below in your debugging process.
1. See [Known Limitations](#known-limitations). User-edit may be required for these and other situations.
1. The [AHK Documentation](https://www.autohotkey.com/docs/v2/v2-changes.htm) should be utilized when converting code from AKHv1 to AHKv2.
2. Comments may be added to the output \[prefixed with `; V1toV2: `\], which provide info to assist with debugging.
3. [This](https://github.com/mmikeww/AHK-v2-script-converter/discussions/325) page provides a list of common conversion issues and potential fixes.
4. [Issues](https://github.com/mmikeww/AHK-v2-script-converter/issues) reported by others may provide potential fixes.
5. If your issue is not found in the last step, feel free to [create a new one](https://github.com/mmikeww/AHK-v2-script-converter/issues/new/choose)
6. Finally, ask for help! On the [discussions page](https://github.com/mmikeww/AHK-v2-script-converter/discussions/categories/q-a-conversion-help), at [AHK forums](https://www.autohotkey.com/boards/viewforum.php?f=82), or using your favorite AI tool.

## Note
You may still have the AutoHotkey V1 binary associated with *.ahk files, the converter is written in V2 so please either [update AutoHotkey](https://www.autohotkey.com/download/) or open the repository in command prompt and run the following command: `"AutoHotKey Exe\AutoHotkeyV2.exe" QuickConvertorV2.ahk`

# Known Limitations
Better support for the following may be included in future updates of the tool.
   * $\color{magenta}\text{Variable Name Conflicts:}$ These are very common and will require manual edits by the user.
   * $\color{magenta}\text{Ternary If Expressions:}$ These lines may require manual edits by the user. 
   * $\color{magenta}\text{Nested labels:}$ Some labels and their references may require manual conversion to/for functions.
   * $\color{magenta}\text{Trailing Commas:}$ Sometimes [trailing commas](https://autohotkey.com/docs/commands/_EscapeChar.htm) can cause conversion issues.
   * $\color{magenta}\text{Gui/GuiControl:}$ Recent improvements have been made, but may still require manual edits. IMPORTANT - READ the [Gui Conversion Modes](#usage-1-converter-user-interface) section above for best results.
   
# Contributing
This project is written/maintained by volunteers who donate their time/talents. If you would like to help improve this tool, there are several ways you can get involved:

### 1. Test and Report Bugs

* $\color{magenta}\text{Convert and Run:}$ Run your AutoHotkey v1 scripts through the tool, then execute the v2 output.
* $\color{magenta}\text{Debug:}$ If you encounter errors, attempt to debug them using the [Post Conversion Guidelines](#post-conversion).
* $\color{magenta}\text{Report:}$ If you still need help with a resolution, please submit the Issue [here](https://github.com/mmikeww/AHK-v2-script-converter/issues).

### 2. Submit Code Fixes & Enhancements

You can write code to address bugs, [issues](https://github.com/mmikeww/AHK-v2-script-converter/issues), [failed conversions](https://github.com/mmikeww/AHK-v2-script-converter/tree/master/tests/Test_Folder/Failed%20conversions), [known limitations](#known-limitations), or [v1-to-v2 changes](https://www.autohotkey.com/docs/v2/v2-changes.htm) that are not yet covered.

When submitting code, please ensure you:

* $\color{magenta}\text{Write/Include a Unit Test:}$ Provide at least one new unit test that demonstrates your fix or feature (see details below).
* $\color{magenta}\text{Check Quality Control:}$ Click the **Run QC Unit Tests** button in the Converter UI. Ensure all tests pass (green checkmark) to verify your changes haven't broken existing tests.
* $\color{magenta}\text{Submit a Pull Request:}$ Once all tests pass, submit your code and new unit tests via a [GitHub Pull Request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests).

### 3. Write Unit Tests

Help expand test coverage by writing standalone unit tests.

* $\color{magenta}\text{Structure:}$ Each test requires a v1 source file and its expected v2 converted output.
* $\color{magenta}\text{Naming:}$ Use the `.ah1` extension for the v1 source file, and `.ah2` for the expected v2 output. Keep the code inside these files concise - just enough to demonstrate a successful conversion.
* $\color{magenta}\text{Location:}$ You can find existing examples for reference in the [Tests\Test_Folder](https://github.com/mmikeww/AHK-v2-script-converter/tree/master/tests/Test_Folder) directory of the project.


# Credits/History
- Frankie who created the [original v2 converter](https://www.autohotkey.com/board/topic/65333-v2-script-converter/)
- Uberi for his [updates to the original](https://www.autohotkey.com/board/topic/65333-v2-script-converter/?p=419671)
- [Mergely](https://github.com/wickedest/Mergely) for the javascript diff library
- Aurelain's [Exo](https://autohotkey.com/boards/viewtopic.php?t=5714) for the interface to run the javascript in an AHK gui
- Mmikeww took Frankie's original converter \[linked above\], and updated it for the latest AHKv2 alpha build. He also added essential unit tests \[using the [Yunit framework](https://github.com/Uberi/Yunit)\] to encourage contributions from others.
- [dmtr99](https://github.com/dmtr99) Updated the code to be able to convert to the V2-Beta syntax
- [Banaanae](https://github.com/Banaanae) Recent contributor, maintainer
- [andymbody](https://github.com/andymbody) Recent contributor
- Others

