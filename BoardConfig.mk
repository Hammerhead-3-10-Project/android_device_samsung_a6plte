#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Samsung Galaxy A6+ (SM-A605FN, a6plte) - device specific board config.
# The platform part (arch, boot header offsets, filesystems, system-as-root, VNDK, graphics...) lives in
# device/samsung/msm8953-common. Values below come from the stock firmware A605FNXXU8CVA1
# (PIT, boot header, vendor manifest, getprop).

DEVICE_PATH := device/samsung/a6plte

include device/samsung/msm8953-common/BoardConfigCommon.mk

# Kernel 4.9.319 built from source (kernel/samsung/a6plte, branch a6plte-4.9 of the local repo): the ifoodplayer
# sdm450 tree plus the A6+ board port (dts, SM5708 battery, sec_ts touch, TFA9872 audio, sensors, ...).
# arm64 kernel, 32-bit userspace (TARGET_ARCH := arm) with a 64-bit binder.
# The 4.9 tree needs clang (r353983d, same as the manual builds); the linker is the gcc 4.9 binutils ld, picked
# through the cross compile prefix, because ld.lld fails on the empty built-in.o archives.
BOARD_MKBOOTIMG_ARGS += --board SRPQL20D008KU
TARGET_KERNEL_SOURCE := kernel/samsung/a6plte
TARGET_KERNEL_CONFIG := a6plte_bringup_defconfig
TARGET_KERNEL_ARCH := arm64
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb
TARGET_KERNEL_CLANG_COMPILE := true
TARGET_KERNEL_CLANG_VERSION := r353983d
# Fallback: the stock 3.18 Image.gz-dtb with ",verify" removed from the dtbs (uncomment and drop the lines above)
# TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image.gz-dtb

# OTA zip: refuse other devices
TARGET_OTA_ASSERT_DEVICE := a6plte

# The vendor partition is built from the files of vendor/samsung/a6plte (stock vendor of A605FNXXU8CVA1)
include vendor/samsung/a6plte/BoardConfigVendor.mk

# Partitions (A605FN PIT)
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 3313500160
BOARD_VENDORIMAGE_PARTITION_SIZE := 503316480
# odm (377487360 B) is not built or flashed: it is the CSC partition of the user's firmware
BOARD_CACHEIMAGE_PARTITION_SIZE := 314572800

# VINTF: the manifest/matrix of the stock vendor (target-level 2) so the build-time check sees what the vendor provides
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(DEVICE_PATH)/compatibility_matrix.xml

# Display (panel Samsung S6E3FA7 FHD, 1080x2220)
TARGET_SCREEN_DENSITY := 420

# Properties specific to this device
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop

# Recovery (the stock recovery partition is replaced by TWRP, see AGENTS.md)
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/recovery.fstab

# SELinux
BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy
