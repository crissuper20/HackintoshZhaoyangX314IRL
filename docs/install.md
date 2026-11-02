# Installing on the ZhaoYang X3-14 IRL (83GX)

The install has three configs. Each one adds to the last, so a failure at any step can go back one stage.

| Stage | File | Graphics |
| --- | --- | --- |
| 1 | `config/config-stage1.sample.plist` | Firmware framebuffer at 1920x1080, no acceleration. Use this to install macOS. |
| 2 | `config/config-stage2.sample.plist` | WhateverXe and AMFIPass turned on. |
| Current | `config/config.sample.plist` | Stage 2 plus audio, the working Bluetooth kexts and the daily boot arguments. |

Every config holds placeholder serials. Generate your own serial, MLB, UUID and ROM before using one, for example with GenSMBIOS and the `MacBookPro16,2` model.

## Exact versions

| Item | Version |
| --- | --- |
| Recovery image | macOS Tahoe 26.6.2 (25G83) |
| Running system | macOS Tahoe 26.7.2 (25G332) |
| OpenCore | 1.0.8, debug build |
| Graphics package | WhateverXe-Graphics 0.3.2 |

Recovery files, to check your download:

| File | SHA-256 |
| --- | --- |
| `BaseSystem.dmg` | `edddd0d5869caaa12e29e6996a04f11590280580976a119dbd42c24fa62fe18e` |
| `BaseSystem.chunklist` | `06f7c498f856341f467ba1faedf2717fb2c172ae0aff4658a1467cbf46b711f9` |

The recovery image is Apple software, so it is not in this repository. In October 2026 Apple's recovery server offered 26.6.2 as the latest version. Download it with `macrecovery.py` from the OpenCore utilities.

The driver gates are exact, so 25G332 is the build this setup is known to work on. WhateverXe needs 26.7 or later, which is why the install starts on 26.6.2 and updates before stage 2.

## BIOS (F2)

- Secure Boot off.
- VT-d off if the option exists. `DisableIoMapper` covers it otherwise.
- DVMT Pre-Allocated at 96 MB if the option exists. If it does, `-igfxdvmt` and the iGPU device properties can go.
- The boot menu is F12. Choose the USB stick in UEFI mode.

Lenovo's consumer BIOS hides most options. This is expected.

## Make the USB stick

The stick is erased, and 8 GB or more is safer. Format it FAT32, GPT preferred, then copy these to its root:

```text
EFI/BOOT/BOOTx64.efi
EFI/OC/...
com.apple.recovery.boot/BaseSystem.dmg
com.apple.recovery.boot/BaseSystem.chunklist
```

Use `EFI` from a release and copy the stage 1 config to `EFI/OC/config.plist`.

## Stage 1: install macOS

1. Boot the stick and pick the recovery entry in OpenCore. It may show as `dmg` or `macOS Base System`.
2. Plug in Ethernet. Recovery downloads the full OS, and the RTL8168 works from the start. Wi-Fi needs HeliPort, which only exists after the install.
3. Install to an external SSD first, and leave the internal Windows disk alone.
4. Finish setup, then disable sleep:

```bash
sudo pmset -a hibernatemode 0 standby 0 sleep 0
```

## Stage 2: acceleration

1. Run Software Update and update to 26.7.2 (25G332) while still on stage 1.
2. Install the WhateverXe-Graphics 0.3.2 package from [b00t0x/WhateverXe-Graphics](https://github.com/b00t0x/WhateverXe-Graphics).
3. Copy the stage 2 config to `EFI/OC/config.plist` and reboot.

If the screen stays black or the boot loops, copy the stage 1 config back from another computer or from Windows. You can also add `-wex-noaccel` to the boot arguments to keep the framebuffer only.

## Current config

Copy `config/config.sample.plist` to `EFI/OC/config.plist`. It adds:

- The SN6140 audio layout, using the AppleALC build from `audio/` and SimpleHDA.
- The Bluetooth kexts `IBTFw251` and `IBTPatch251` in place of IntelBluetoothFirmware and IntelBTPatcher.
- WhateverXe build ONCE20, tag `once20-checkpoint` of [crissuper20/WhateverXe](https://github.com/crissuper20/WhateverXe).

`tools/collect-linux.sh` is an optional read-only hardware capture for an Ubuntu live USB. It collects the VBT, ACPI tables, CPUID, codec dump and USB and PCI topology.

## If the boot stops

| Where | Try |
| --- | --- |
| Right after `EXITBS:START` | Toggle `Booter > Quirks > DevirtualiseMmio`, and check VT-d is off. |
| `EB.MM.AKM` or no slide | Disable Windows Fast Startup and keep `ProvideCustomSlide`. |
| Trackpad dead | Use a USB mouse, then check `ioreg -p IOService -l \| grep -i voodoo`. |
| Stuck at PCI configuration | Remove `-igfxdvmt`, or go back to stage 1. |
