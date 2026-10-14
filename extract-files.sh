#!/bin/bash
#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Usage: ./extract-files.sh [-n|--no-cleanup] [-s|--section SECTION] [path/to/dump | adb]
#   ./extract-files.sh /home/fenixdev/Scrivania/progetto/firmware/extracted

set -e

export DEVICE=a6plte
export DEVICE_COMMON=msm8953-common
export VENDOR=samsung

"./../../${VENDOR}/${DEVICE_COMMON}/extract-files.sh" "$@"
