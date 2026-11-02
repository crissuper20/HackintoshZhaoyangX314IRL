#!/usr/bin/env python3
# Builds AppleALC with the SN6140 profile without Xcode, using WEX's kext flags.
# Needs ~/wex-audio/AppleALC, ~/WhateverXe/Lilu.kext and ~/WhateverXe/MacKernelSDK.
import os,pathlib,plistlib,shutil,subprocess
A=pathlib.Path.home()/'wex-audio/AppleALC'
W=pathlib.Path.home()/'WhateverXe'
B=A/'build';B.mkdir(exist_ok=True)
lilu=W/'Lilu.kext/Contents/Resources';sdk=W/'MacKernelSDK'
def run(c,**k):subprocess.run([str(x) for x in c],check=True,cwd=A,**k)
run(['clang++','-fobjc-arc','-framework','Foundation','ResourceConverter/main.mm','-o',B/'ResourceConverter'])
env=dict(os.environ,PROJECT_DIR=str(A),TARGET_BUILD_DIR=str(B))
run(['bash','-e','ResourceConverter/generate.sh'],env=env,stdout=subprocess.DEVNULL)
base=['xcrun','clang++','-arch','x86_64','-std=c++17','-O0','-g','-fapple-kext','-fno-exceptions','-fno-rtti',
 '-fno-stack-protector','-fno-builtin','-fno-asynchronous-unwind-tables','-mno-red-zone','-nostdinc','-Wno-everything',
 '-DKERNEL','-DKERNEL_PRIVATE','-D__APPLE__','-D__MACH__','-I'+str(sdk/'Headers'),'-I'+str(lilu),'-I'+str(A/'AppleALC'),
 '-I'+str(A/'AppleALC/ALCUserClient'),'-I'+str(A/'AppleALC/ALCUserClientProvider'),'-DHAVE_ANALOG_AUDIO','-DPRODUCT_NAME=AppleALC',
 '-DMODULE_VERSION=1.9.9','-mmacosx-version-min=10.6','-DAPPLE_KEXT_ASSERTIONS=1','-DDRIVER_PRIVATE','-DAPPLE','-DNeXT',
 '-fno-common','-fasm-blocks','-mmmx','-msse','-msse2','-msse3','-mssse3','-mfpmath=sse','-DDEBUG=1']
objects=[]
for source in sorted((A/'AppleALC').rglob('*.cpp'))+[lilu/'Library/plugin_start.cpp']:
    obj=B/(source.stem+'.o');print('cc',source.name,flush=True)
    run(base+['-c',source,'-o',obj]);objects.append(obj)
K=B/'AppleALC.kext/Contents'
shutil.rmtree(K.parent,ignore_errors=True);(K/'MacOS').mkdir(parents=True)
run(['xcrun','ld','-arch','x86_64','-kext','-undefined','dynamic_lookup','-no_fixup_chains','-macos_version_min','10.6',
 '-o',K/'MacOS/AppleALC',*objects,sdk/'Library/x86_64/libkmod.a'])
text=(A/'AppleALC/AppleALC-Info.plist').read_text()
for old,new in {'$(EXECUTABLE_NAME)':'AppleALC','$(PRODUCT_BUNDLE_IDENTIFIER)':'as.vit9696.AppleALC',
 '$(PRODUCT_NAME:rfc1034identifier)':'AppleALC','$(PRODUCT_NAME)':'AppleALC','$(MODULE_VERSION)':'1.9.9'}.items():
    text=text.replace(old,new)
info=plistlib.loads(text.encode())
pins=plistlib.load(open(A/'Resources/PinConfigs.kext/Contents/Info.plist','rb'))
info['IOKitPersonalities']['as.vit9696.AppleALC']=pins['IOKitPersonalities']['as.vit9696.AppleALC'] # As merge_pinconfigs.sh.
plistlib.dump(info,open(K/'Info.plist','wb'))
print('built',K.parent)
