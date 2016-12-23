# AHK-v2-script-converter
This script will attempt to convert a script written in AHK v1 to the correct syntax so that it works in [AHK v2](https://autohotkey.com/v2/).  
It is useful to quickly convert some of the bigger syntax changes. Afterwards you can investigate the converted version for other minor changes that the converter didn't cover.

I took Frankie's original converter linked below, and updated it to work with the latest AHK v2 alpha build.  
I've also added essential unit tests using the [Yunit framework](https://github.com/Uberi/Yunit) to encourage contributions from others.

However, this project is way more ambitious that I originally thought, and __it needs a lot of work__. See below for how you can [contribute](#contributing).

![screenshot](https://github.com/mmikeww/AHK-v2-script-converter/blob/master/screenshot.jpg)

# Usage
## Convert v1 script to v2
1. [Download](https://github.com/mmikeww/AHK-v2-script-converter/archive/master.zip) the full repo. Then run the included `v2converter.exe` file
2. Choose your input `scriptfile.ahk` written for AHK v1.  
   The converted script will be named `scriptfile_v2new.ahk` in the same directory
3. Look over the Visual Diff to manually inspect the changes

## Note
The `v2converter.exe` file (as well as the `tests\Tests.exe` file) is simply a renamed copy of the `AutoHotkeyU32-v2-a076.exe` interpreter file that is included in the v2-a076 zip download. The interpreter alone does nothing without passing a script to it. But here, we take advantage of the [default scriptfile feature](https://lexikos.github.io/v2/docs/Scripts.htm#defaultfile) where the v2converter.exe file will look for a file named v2converter.ahk and automatically run it. You can make changes to the .ahk file and then just run the .exe. The reason for doing this is because most people will still have AHK v1 installed and associated with `*.ahk` files. So it would be inconvenient to run this converter without some workarounds. Likewise, the `diff\VisualDiff.exe` file is just a renamed `AutoHotkeyU32-v1.1.24.02.exe`

# Known Issues
The converter is not complete. That is, it does not detect all things that need to be changed to make sure the script works in v2. However, for the things that it DOES change, everything should hopefully work, except for the following. Here are the instances that are known to fail:
1. There is a [little known feature](https://autohotkey.com/docs/commands/_EscapeChar.htm) where commas don't need to be escaped if they are in the last parameter of a command. This converter can detect those, except when the command is an IfCommand. This is because the converter needs to check for a same-line action, such as in `IfEqual, var, value, Sleep, 500`. The unit tests for those unescaped commas are commented out.

# Contributing
There is a lot of work to do and many commands and functions that still need to be changd. There are also many edge cases when trying to parse script code and convert it. Of course, whenever making changes to the code, you should be constantly running the unit tests to confirm that things are still working. Simply run the `tests\Tests.exe` file and pray for green.  

Here are a few ways you can help:

- Use it to convert your v1 scripts  
  When you find errors or mistakes in the conversion, [open an issue here on github](https://github.com/mmikeww/AHK-v2-script-converter/issues)
- Write unit tests  
  You don't even need to write implementation code. Simply write some tests. There are existing commands that the original converter supported that have not been tested with my changes, such as `StringTrimRight`. Follow the existing format in the `tests\Tests.ahk` file.
- Fix existing failing tests  
  There is currently a failing test named `Continuation_NewlinePreceding()` that is commented out in the Tests.ahk file.
  This needs implementation.
- Work on any existing [issues](https://github.com/mmikeww/AHK-v2-script-converter/issues)
- Refactor the code  
  The code isn't in very good condition. And you can lean on the unit testing suite as you try to make it better.
- Add support for other changes. You can find the definitive list here: [v2-changes](https://autohotkey.com/v2/v2-changes.htm)  
  This would include adding support for new commands or other syntax changes. Follow the example in [this commit](https://github.com/mmikeww/AHK-v2-script-converter/commit/6f9fce882a846b15776431a4b27cac9a2aba30d3).

And of course, create a Pull Request with your changed code

# Credits
- Frankie who created the [original v2 converter](https://autohotkey.com/board/topic/65333-v2-script-converter/)
- Uberi for his [updates to the original](https://autohotkey.com/board/topic/65333-v2-script-converter/?p=419671)
- [Mergely](https://github.com/wickedest/Mergely) for the javascript diff library
- Aurelain's [Exo](https://autohotkey.com/boards/viewtopic.php?t=5714) for the interface to run the javascript in an AHK gui
- I'm sure many others
