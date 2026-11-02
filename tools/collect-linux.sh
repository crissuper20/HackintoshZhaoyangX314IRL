#!/usr/bin/env bash
# Hardware capture for the 83GX hackintosh, run from an Ubuntu live USB ("Try Ubuntu").
#   sudo bash collect-linux.sh [output-dir]
# Read-only: dumps tables, registers and logs; changes nothing on the disk or in firmware.
# Output: one folder plus a .tar.gz next to this script (put it on the stick, bring it back).
set -u
OUT="${1:-$(dirname "$(readlink -f "$0")")/83gx-linux-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$OUT"
cd "$OUT" || exit 1
[ "$(id -u)" -eq 0 ] || { echo "run with sudo"; exit 1; }

run() {  # run <file> <command...>: save output, never stop on failure
    local f="$1"; shift
    echo "== $*" | tee -a _index.txt
    "$@" >"$f" 2>&1 || echo "   (exit $?)" | tee -a _index.txt
}

echo "Installing tools (needs internet; skip errors if offline)"
add-apt-repository -y universe >/dev/null 2>&1
apt-get update -qq >/dev/null 2>&1
apt-get install -y -qq acpica-tools cpuid dmidecode pciutils usbutils edid-decode intel-gpu-tools alsa-utils >/dev/null 2>&1

# --- firmware tables: everything, including APIC/DMAR/MCFG that Windows' registry does not expose
mkdir -p acpi && (cd acpi && acpidump -b >/dev/null 2>&1; cp /sys/firmware/acpi/tables/* . 2>/dev/null; iasl -d ./*.dat >/dev/null 2>&1)
run dmidecode.txt dmidecode
run efivars.txt ls -la /sys/firmware/efi/efivars

# --- CPU: raw CPUID (leaf 1 EBX[23:16] = logical per package, leaf 0x1A = P/E core type), MSRs
run cpuid-raw.txt cpuid -r
run cpuid.txt cpuid
run lscpu.txt lscpu -e=CPU,CORE,SOCKET,MAXMHZ,MINMHZ
modprobe msr 2>/dev/null
if command -v rdmsr >/dev/null; then
    run msr-e2-cfglock.txt rdmsr -a 0xe2   # bit 15 set = CFG Lock on (AppleXcpmCfgLock needed)
fi
python3 - >msr-e2-cfglock.txt 2>&1 <<'EOF'
import os, struct
v = struct.unpack("<Q", os.pread(os.open("/dev/cpu/0/msr", os.O_RDONLY), 8, 0xE2))[0]
print(f"MSR 0xE2 = {v:#x}  CFG Lock (bit 15) = {'ON' if v >> 15 & 1 else 'off'}")
EOF

# --- PCI / USB topology (for USB mapping and device paths)
run lspci.txt lspci -nnvvv
run lspci-tree.txt lspci -tvnn
run lsusb.txt lsusb -tv
run lsusb-v.txt lsusb -v
for p in /sys/bus/usb/devices/usb*/; do echo "$p $(cat "$p"/../uevent 2>/dev/null | grep PCI_SLOT)"; done >usb-controllers.txt

# --- Graphics: VBT (eDP/port wiring for WhateverXe), EDID, i915 state, display registers
D=$(ls -d /sys/kernel/debug/dri/*/i915_vbt 2>/dev/null | head -1)
[ -n "$D" ] && cp "$D" vbt.bin
cat /sys/kernel/debug/dri/*/i915_vbt >/dev/null 2>&1
for f in i915_display_info i915_edp_psr_status i915_dmc_info i915_gem_objects i915_capabilities i915_frequency_info i915_power_domain_info i915_shared_dplls_info i915_sseu_status gt0/sseu_status gt0/sseu_topology; do
    for d in /sys/kernel/debug/dri/*/; do [ -e "$d$f" ] && cp "$d$f" "i915-$(echo "$f" | tr / _).txt" 2>/dev/null; done
done
for e in /sys/class/drm/card*-*/edid; do [ -s "$e" ] && { n=$(basename "$(dirname "$e")"); cp "$e" "edid-$n.bin"; edid-decode "$e" >"edid-$n.txt" 2>&1; }; done
command -v intel_reg >/dev/null && run intel_reg-dump.txt intel_reg dump
command -v intel_vbt_decode >/dev/null && [ -f vbt.bin ] && run vbt-decoded.txt intel_vbt_decode --file vbt.bin

# --- Audio: SN6140 codec dump (pins, widgets, connections) for an AppleALC layout
for c in /proc/asound/card*/codec#*; do cp "$c" "codec-$(basename "$(dirname "$c")")-$(basename "$c" | tr '#' '_').txt"; done
run aplay.txt aplay -l
run arecord.txt arecord -l

# --- Input: trackpad / keyboard / I2C / GPIO
run i2c-devices.txt bash -c 'for d in /sys/bus/i2c/devices/*; do echo "$d $(cat $d/name 2>/dev/null) $(cat $d/firmware_node/hid 2>/dev/null)"; done'
run gpio.txt cat /sys/kernel/debug/gpio
run pinctrl.txt bash -c 'for f in /sys/kernel/debug/pinctrl/*/pins; do echo "### $f"; cat "$f"; done'
run interrupts.txt cat /proc/interrupts
run input-devices.txt cat /proc/bus/input/devices

# --- Storage, network, power
run nvme.txt bash -c 'lsblk -o NAME,MODEL,SIZE,TYPE,FSTYPE,PARTLABEL; for n in /dev/nvme?; do nvme id-ctrl "$n" 2>/dev/null; done'
run net.txt ip -d link
run battery.txt bash -c 'for b in /sys/class/power_supply/*; do echo "### $b"; cat "$b/uevent"; done'
run sleep-states.txt bash -c 'cat /sys/power/state /sys/power/mem_sleep'

# --- Kernel view of everything above
run dmesg.txt dmesg
run modules.txt lsmod
run cmdline.txt cat /proc/cmdline

cd .. && tar czf "$(basename "$OUT").tar.gz" "$(basename "$OUT")" && echo "Done: $OUT.tar.gz"
