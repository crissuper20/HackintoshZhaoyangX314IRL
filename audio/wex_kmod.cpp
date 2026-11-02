// Xcode generates this for a kext target. Same lifecycle block as WhateverXe's kern_start.cpp.
#include <mach/mach_types.h>
#include <mach/kmod.h>
#include <libkern/libkern.h>
extern "C" {
extern kern_return_t _start(kmod_info_t *, void *);
extern kern_return_t _stop(kmod_info_t *, void *);
extern kern_return_t AppleALC_kern_start(kmod_info_t *, void *);
extern kern_return_t AppleALC_kern_stop(kmod_info_t *, void *);
__attribute__((visibility("default"))) KMOD_EXPLICIT_DECL(as.vit9696.AppleALC, "1.9.9", _start, _stop)
__attribute__((visibility("hidden"))) kmod_start_func_t *_realmain = AppleALC_kern_start;
__attribute__((visibility("hidden"))) kmod_stop_func_t *_antimain = AppleALC_kern_stop;
__attribute__((visibility("hidden"))) int _kext_apple_cc = __APPLE_CC__;
}
