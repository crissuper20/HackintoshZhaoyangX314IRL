# SN6140 audio

Custom AppleALC profile for the Conexant SN6140 codec in this laptop, layout 21.

- `SN6140/`: codec resources. Copy to `Resources/SN6140` in AppleALC.
- `PinConfigs-SN6140.diff`: pin configuration and wake verbs, based on Andres ZeroCross's Conexant CX8070 profile for the Lenovo ThinkPad E14.
- `wex_kmod.cpp`: lifecycle block needed to build without Xcode. Copy to `AppleALC/` in AppleALC.
- `build-alc.py`: builds a debug AppleALC without Xcode. It expects AppleALC in `~/wex-audio/AppleALC`, and Lilu.kext and MacKernelSDK in `~/WhateverXe`.

Base commit is in `AppleALC-base-commit.txt`. These files derive from AppleALC and stay under its licence, in `AppleALC-LICENSE.txt`.

Set `alcid=21` in boot-args.
