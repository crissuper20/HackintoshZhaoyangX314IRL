# Hackintosh: Lenovo ZhaoYang X3-14 IRL

macOS 26.7.2 (25G332) on the Lenovo ZhaoYang X3-14 IRL 83GX. This repository holds what is specific to this laptop.

**This is an experimental, debug-only setup.** It can freeze, panic or show wrong graphics. Use it at your own risk, and keep a working USB installer and backups. Not for use by anyone under 18.

## Hardware

| Part | Details |
| --- | --- |
| CPU | Intel Core i3-1315U |
| GPU | Intel UHD (Raptor Lake-U), `8086:A7A9` |
| RAM | 16 GB |
| Audio | Conexant SN6140, layout 21 |
| Wi-Fi and Bluetooth | Intel CNVi `8086:51F1`, Bluetooth `8087:0026` |
| SMBIOS | MacBookPro16,2 |

## Status

Working on this machine: desktop on the internal panel, Metal and OpenGL apps, and Bluetooth.

Known problems:

- GPU hangs can freeze the machine and may not recover.
- Blender loses its viewport grid when viewport anti-aliasing samples are on.
- Hardware H.264 decoding stalls.
- HDMI shows wrong colours.
- Metal and WindowServer memory leaks appear in long sessions.
- Muck shows pale patches on its grass; the cause is unknown.

## Layout

- `docs/install.md`: exact recovery version, BIOS settings and each install stage.
- `docs/hardware.md`: devices, drivers and why each SSDT exists.
- `config/`: stage 1, stage 2 and current OpenCore configs, all with placeholder serials.
- `acpi/`: compiled SSDTs in use.
- `audio/`: custom SN6140 audio profile and build script.
- `docs/boot-args.md`: what each boot argument does.
- `tools/make-efi.py`: builds the release zip.
- `tools/collect-linux.sh`: optional hardware capture from a Linux live USB.

## Using a release

Releases hold a ready-made debug OpenCore folder. All current releases are debug builds.

1. Generate your own serial, MLB, UUID and ROM, for example with GenSMBIOS, and put them in `OC/config.plist`. The placeholders must not be used as they are.
2. Follow `docs/install.md`. The Apple drivers and the recovery image are not included here.
3. `HfsPlus.efi` is left out because it is Apple software. Add a driver of your own if you need HFS+ in OpenCore, and enable it in the config.

The graphics kext is build ONCE20, tag `once20-checkpoint` of [crissuper20/WhateverXe](https://github.com/crissuper20/WhateverXe), a fork of [b00t0x/WhateverXe](https://github.com/b00t0x/WhateverXe). The rest are upstream kexts, each under its own licence: Lilu, AppleALC, VirtualSMC, RestrictEvents, NVMeFix, CpuTscSync, CpuTopologyRebuild, ECEnabler, AMFIPass, RealtekRTL8111, itlwm, IntelBluetoothFirmware, USBToolBox, VoodooPS2, VoodooI2C and SimpleHDA.
