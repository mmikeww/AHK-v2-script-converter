# AHK-v2-script-converter
This script will attempt to convert a script written in AHK v1 to the correct syntax so that it works in [AHK v2](https://autohotkey.com/v2/).  
It is useful to quickly convert some of the bigger syntax changes. Afterwards you can investigate the converted version for other minor changes that the converter didn't cover.

I took Frankie's original converter linked below, and updated it to work with the latest AHK v2 alpha build.  
I've also added essential unit tests using the [Yunit framework](https://github.com/Uberi/Yunit) to encourage contributions from others.

However, this project is way more ambitious that I originally thought, and there is still loads more work to be done. See below for how you can [contribute](#contributing).

# Usage
## Convert v1 script to v2
- Run the included `v2converter.exe` file
- Choose your input `scriptfile.ahk` written for AHK v1
- The converted script will be named `scriptfile_New.ahk` in the same directory

## Run unit tests
- Run the `tests\Tests.exe` file

## Note
The `v2converter.exe` file (as well as the `tests\Tests.exe` file) is simply a renamed copy of the `AutoHotkeyU32.exe` file that is included in the v2-a076 zip download. The reason for this is because most people will still have AHK v1 installed and associated with `*.ahk` files. So it would be inconvenient to run the converter without some workarounds. This way, we take advantage of the [default scriptfile feature](https://lexikos.github.io/v2/docs/Scripts.htm#defaultfile) where the v2converter.exe file will look for a file named v2converter.ahk and run it. You can make changes to the .ahk file and then just run the .exe

# Contributing
There are many edge cases when trying to parse script code and convert it. Here are a few ways you can help:
- Write unit tests  
  You don't even need to write implementation code. Simply write some tests. There are existing commands that the original converter supported that have not been tested with my changes, such as `StringTrimRight` and other String functions. Follow the existing format in the `tests\Tests.ahk` file. See [this commit](https://github.com/mmikeww/AHK-v2-script-converter/commit/1e32043455abbd2f1e42c51c126d7c4f20a6be88) for an example.
- Fix existing failing tests  
  I have written tests already for the conversion of default function params from to use `:=` instead of `=`.  
  These tests currently fail and need implementation.  
- Add support for other changes. You can find the definitive list here: [v2-changes](https://autohotkey.com/v2/v2-changes.htm)  
  This would include adding support for new commands or other syntax changes. Follow the example in [this commit](https://github.com/mmikeww/AHK-v2-script-converter/commit/6f9fce882a846b15776431a4b27cac9a2aba30d3).

And of course, create a Pull Request with your changed code

# History / Credits
- Frankie who created the [original converter](https://autohotkey.com/board/topic/65333-v2-script-converter/)
- Uberi for his [updates to the original](//autohotkey.com/board/topic/65333-v2-script-converter/?p=419671)
- I'm sure many others
