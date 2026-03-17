# AHK-v2-script-converter
This script will attempt to convert a script written in AHK v1 to the correct syntax so that it works in [AHK v2](https://autohotkey.com/v2/).  
It is useful to quickly convert some of the bigger syntax changes. Afterwards you can investigate the converted version for other minor changes that the converter didn't cover.

I took Frankie's original converter linked below, and updated it to work with the latest AHK v2 alpha build.  
I've also added essential unit tests using the [Yunit framework](https://github.com/Uberi/Yunit) to encourage contributions from others.

However, this project is way more ambitious that I originally thought, and __it needs a lot of work__. See below for how you can [contribute](#contributing).

# Usage
## Usage 1
1. [Download](https://github.com/mmikeww/AHK-v2-script-converter/archive/master.zip) the full repo. Then run the included `QuickConvertorV2.ahk` file with AHK V2
2. Select a string in another program and press XButton1 to convert it, or paste it in the first Edit and press the convert button (orange arrow).
3. When the cursor is on a function in the edit field, press F1 to search the function in the documentation.
4. You can run and close the V1 and V2 code with the play buttons.
5. There are also compare buttons to see better the difference between the scripts.
6. When working on ConvertFuncs.ahk, please set TestMode on in the Gui Menu Settings, in this mode, all the confirmed tests will be checked if the result stays the same. In this mode you can also save tests easily.
![screenshot](https://github.com/mmikeww/AHK-v2-script-converter/blob/master/images/Quick%20Convertor%20V2.png)

## Usage 2 (alternative)
1. [Download](https://github.com/mmikeww/AHK-v2-script-converter/archive/master.zip) the full repo. Then run the included `v2converter.ahk` script with AHK v2
2. Choose your input `scriptfile.ahk` written for AHK v1.  
   The converted script will be named `scriptfile_newV2.ahk` in the same directory
   Use `v2converter.ahk -h` in cmd to use the CLI
   You can modify parts of how the script behave from editing variables inside the script
3. Look over the Visual Diff to manually inspect the changes
![screenshot](https://github.com/mmikeww/AHK-v2-script-converter/blob/master/images/screenshot.jpg)

## Usage 3 (Converter UI)
1. [Download](https://github.com/mmikeww/AHK-v2-script-converter/archive/master.zip) the full repo. Then run the included `Converter_UI.ahk` script with AHK v2
2. Use buttons on the left as shortcuts to run # 2 or # 1 above.
   * Convert V1 Script File: Runs v2converter to select/convert a script file. See Usage 2 above.
   * Convert V1 Code Fragment: Runs QuickConvertorV2 for v1 code paste. See Usage 1:4 above. Paste v1 code fragment in left pane, convert using orange arrow button (bottom/center). 
   * Run QC Unit Tests: Runs QuickConvertorV2 in Unit-Test Mode (for project contributors) - See Usage 1:6 above. Shift-Click this button to show failed unit-tests (also).
3. Some conversion settings can be adjusted from UI tabs [settings are still a work in progress].
   * Tab 1: Save all settings from other tabs (Manual/Auto). Auto-save is recommended.
   * Gui Tab: Provides several modes for Gui/GuiControl conversion. Also allows user to define the default GuiName and control prefix for v2 variable names (for Orig/Simple modes).
   * HK Tab: Will eventually provide hotkey filtering to improve conversion performance.
   * General Tab: Provides general conversion settings.
4. Gui Conversion Modes:
   * Orig mode: Provides Gui conversion using original routines. This is being phased out for updated modes below.
   * Simple mode: Updated version of Orig mode. Provides similar (but improved) output, compared to Orig mode. Recommended for converting simple (non-dynamic) v1 Gui syntax.
   * Dynamic mode: Provides the best Gui conversion support, including limited support for dynamic attributes. Such as within loops, func params, ClassNN names, and spanning multiple scopes. The trade off? The v2 syntax is much different than Simple/Orig mode. It also requires an #include file [before and AFTER conversion]. The file monitors changes to gui/control code and objects in real time... similar to behavior for v1 Gui handling.
   * Auto mode: Analyzes the v1 source code and selects the 'best mode' automatically (Simple or Dynamic).

![screenshot](https://github.com/mmikeww/AHK-v2-script-converter/blob/master/images/Converter_UI.png)

## Post conversion
If you find that the script does not work, please go through the troubleshooting steps below
1. Review all comments, they are prefixed with `; V1toV2: ` and can provide fixes on code that the converter can't handle
2. Read [this](https://github.com/mmikeww/AHK-v2-script-converter/discussions/325) page listing many of the common conversion issues and their fixes
3. Check [issues](https://github.com/mmikeww/AHK-v2-script-converter/issues), if others users have experienced this issue we create potential fixes before we implement it.
4. If nobody has experienced your issue, [create a new one](https://github.com/mmikeww/AHK-v2-script-converter/issues/new/choose)
5. Finally ask for help! Either on the [discussions page](https://github.com/mmikeww/AHK-v2-script-converter/discussions/categories/q-a-conversion-help) or at [AHK forums](https://www.autohotkey.com/boards/viewforum.php?f=82)

## Note
You may still have the AutoHotkey V1 binary associated with *.ahk files, the converter is written in V2 so please either [update AutoHotkey](https://www.autohotkey.com/download/) or open the repository in command prompt and run the following command: `"AutoHotKey Exe\AutoHotkeyV2.exe" QuickConvertorV2.ahk`

# Known Issues
The converter is not complete. That is, it does not detect all things that need to be changed to make sure the script works in v2. However, for the things that it DOES change, everything should hopefully work, except for the following. Here are the instances that are known to fail:
1. There is a [little known feature](https://autohotkey.com/docs/commands/_EscapeChar.htm) where commas don't need to be escaped if they are in the last parameter of a command. This converter can detect those, except when the command is an IfCommand. This is because the converter needs to check for a same-line action, such as in `IfEqual, var, value, Sleep, 500`. The unit tests for those unescaped commas are commented out.
2. Converting Gui is becoming better, the only big issue is the handling of the g-labels, the methods are completely different.

# Contributing
There is a lot of work to do and many commands and functions that still need to be changed. There are also many edge cases when trying to parse script code and convert it. Of course, whenever making changes to the code, you should be constantly running the unit tests to confirm that things are still working.  First run `QuickConvertorV2.ahk` with `Settings -> Testmode` on, make sure no tests fail. Then run the `tests\Tests.ahk` file and pray for green.

Here are a few ways you can help:

- Use it to convert your v1 scripts  
  When you find errors or mistakes in the conversion, [open an issue here on github](https://github.com/mmikeww/AHK-v2-script-converter/issues)
- Write tests  
  You don't even need to write implementation code. Simply write some tests. There are existing commands that the original converter supported that have not been tested with my changes, such as `StringTrimRight`. Follow the existing format in the `tests\Tests.ahk` file.
- Fix/add existing failing tests  
  In the folder [Failed conversions](https://github.com/mmikeww/AHK-v2-script-converter/tree/master/tests/Failed%20conversions) we put the tests that are currenly failing as a ah1 file. The correct conversion is the ah2 file.
- Work on any existing [issues](https://github.com/mmikeww/AHK-v2-script-converter/issues)
- Refactor the code  
  The code isn't in very good condition. And you can lean on the unit testing suite as you try to make it better.
- Add support for other changes. You can find the definitive list here: [v2-changes](https://autohotkey.com/v2/v2-changes.htm)  
  This would include adding support for new commands or other syntax changes. Follow the example in [this commit](https://github.com/mmikeww/AHK-v2-script-converter/commit/2c53a37550aca7ecc2c890677d4e13ea72e7c682).

And of course, create a Pull Request with your changed code

# Credits
- Frankie who created the [original v2 converter](https://www.autohotkey.com/board/topic/65333-v2-script-converter/)
- Uberi for his [updates to the original](https://www.autohotkey.com/board/topic/65333-v2-script-converter/?p=419671)
- [Mergely](https://github.com/wickedest/Mergely) for the javascript diff library
- Aurelain's [Exo](https://autohotkey.com/boards/viewtopic.php?t=5714) for the interface to run the javascript in an AHK gui
- Mmikeww and AHK_User updated the script to start working in V2-Beta
- AHK_User (=dmtr99) Updated the code to be able to convert to the V2-Beta syntax and is currently working on it
- I'm sure many others
