# Boot arguments

Current debug set, all in `config/config.sample.plist`.

| Argument | Purpose |
| --- | --- |
| `-v keepsyms=1 debug=0x100 msgbuf=1048576` | Verbose boot, symbols in panics, no reboot on panic, larger kernel log |
| `alcid=21` | SN6140 audio layout |
| `-alcdbg -shdadbg liludump=120` | AppleALC, SimpleHDA and Lilu debug logs |
| `-ibtcompatbeta` | Allows Intel Bluetooth on this macOS version |
| `-cputsbeta -cputsdbg` | CpuTscSync on this macOS version, with logs |
| `-allow3d -disablegfxfirmware -igfxdvmt` | WhateverXe graphics options used on this machine |
| `-wexdbg -wex-display13-trace -wex-display-trace -wexhangcap` | WhateverXe debug logging and GPU hang capture |
| `-vi2c-force-polling` | VoodooI2C polling mode for the touchpad |

Verbose boot with heavy debug logging can stall on the console. A long pause is not always a hang.
