#!/usr/bin/env python3
"""Builds the debug EFI zip from an EFI folder, using the sample config.

Usage: make-efi.py EFI_FOLDER OUTPUT.zip
Leaves out HfsPlus.efi and refuses to finish if the source config's real
serial, MLB, UUID or ROM appears in any packed file.
"""
import base64, pathlib, plistlib, shutil, sys, tempfile

source, output = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2]).resolve()
repo = pathlib.Path(__file__).resolve().parents[1]
generic = plistlib.load(open(source / 'OC/config.plist', 'rb'))['PlatformInfo']['Generic']
secrets = [generic[k].encode() for k in ('SystemSerialNumber', 'MLB', 'SystemUUID')]
secrets += [generic['SystemUUID'].lower().encode(), generic['ROM'], generic['ROM'].hex().encode()]
secrets += [generic['ROM'].hex().upper().encode(), base64.b64encode(generic['ROM'])]

with tempfile.TemporaryDirectory() as tmp:
    efi = pathlib.Path(tmp) / 'EFI'
    shutil.copytree(source, efi, ignore=shutil.ignore_patterns('.*', 'HfsPlus.efi'))
    shutil.copy(repo / 'config/config.sample.plist', efi / 'OC/config.plist')
    for path in efi.rglob('*'):
        if path.is_file():
            data = path.read_bytes()
            if any(secret in data for secret in secrets):
                sys.exit('private value found in ' + str(path.relative_to(efi)))
    output.parent.mkdir(exist_ok=True)
    shutil.make_archive(str(output.with_suffix('')), 'zip', tmp, 'EFI')
print('built', output)
