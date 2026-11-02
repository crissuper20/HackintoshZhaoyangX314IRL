# Hardware notes

## Devices

| Device | ID | Driver | Notes |
| --- | --- | --- | --- |
| CPU i3-1315U, 2P+4E | | ProvideCurrentCpuInfo, CpuTopologyRebuild | `Cpuid1Data` forces 128 logical processors per package, which clears the `EXITBS` freeze. |
| GPU | `8086:A7A9` | WhateverXe | Raptor Lake-U, never supported by Apple. |
| Ethernet RTL8168 | | RealtekRTL8111 | The most reliable network during setup. |
| Wi-Fi | `8086:51F1` | itlwm | Needs the HeliPort app. |
| Bluetooth | `8087:0026` | IBTFw251, IBTPatch251, BlueToolFixup | `-ibtcompatbeta` allows it on Tahoe. |
| Keyboard | PS/2 | VoodooPS2 | |
| Trackpad ELAN06FA, I2C1 | | VoodooI2C, VoodooI2CHID | Runs in polling mode with `-vi2c-force-polling`. The I2C1 `device-id` is spoofed. |
| NVMe UMIS | | NVMeFix | |
| Audio SN6140 | `14F1:1F87` | AppleALC layout 21, SimpleHDA | See `audio/README.md`. |
| USB | | USBToolBox, UTBDefault | No custom port map yet. |

## ACPI

Built from this machine's own tables.

| SSDT | Why |
| --- | --- |
| `SSDT-PLUG-ALT` | Maps the 64 `ACPI0007` PRxx devices to Processor objects, with plugin-type on the first. |
| `SSDT-EC-USBX-LAPTOP` | The real EC is `LPCB.EC0`. Adds a fake `EC` and USB power. |
| `SSDT-RTCAWAC` | Sets `STAS = 1`, so the legacy RTC is on and AWAC is off. |
| `SSDT-XOSI` | Used with the `_OSI to XOSI` DSDT patch, because `TPD0._CRS` returns no I2C descriptor when `OSYS < 0x07DC`. |
| `SSDT-PNLF` | Backlight for the internal panel. |

## Sleep

Sleep is not expected to work. Keep it off with the `pmset` command in `install.md`.

## Sources

- [X1 Carbon G11 on Tahoe](https://github.com/dssoftx/Hackintosh-X1Carbon-G11-IrisXe-Tahoe), for the Raptor Lake setup and the `EXITBS` fix.
- [b00t0x/WhateverXe](https://github.com/b00t0x/WhateverXe), the graphics base.
- [samranahmad09/WhateverXe-RaptorLakeP](https://github.com/samranahmad09/WhateverXe-RaptorLakeP), the Raptor Lake-P fork.
- [acidanthera/AppleALC](https://github.com/acidanthera/AppleALC), the audio base.
