#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Extra steps of the full OTA zip of the Galaxy A6+ (a6plte).

import os

import common


def FullOTA_InstallEnd(info):
    # The ROM is "system-only": vendor, modem and bootloader stay the stock Samsung ones. The only change to
    # vendor is the userdata line of fstab.qcom (see install/patch_vendor.sh).
    here = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(here, 'install', 'patch_vendor.sh')) as f:
        data = f.read()
    common.ZipWriteStr(info.output_zip, 'install/patch_vendor.sh', data, perms=0o755)

    script = info.script
    script.Print('Disabling force-encrypt in the stock vendor fstab...')
    script.AppendExtra('package_extract_file("install/patch_vendor.sh", "/tmp/patch_vendor.sh");')
    script.AppendExtra('set_metadata("/tmp/patch_vendor.sh", "uid", 0, "gid", 0, "mode", 0755);')
    script.AppendExtra('assert(run_program("/tmp/patch_vendor.sh") == 0);')
