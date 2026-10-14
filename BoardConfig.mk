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

# Kernel: the stock Image.gz-dtb (arm64 Image + 5 appended dtb) until the kernel is built from source
BOARD_MKBOOTIMG_ARGS += --board SRPQL20D008KU
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image.gz-dtb
# Step 2 (kernel from source, branch lineage-17.1 of the Samsung opensource tree):
# TARGET_KERNEL_SOURCE := kernel/samsung/a6plte
# TARGET_KERNEL_CONFIG := a6plte_sea_open_defconfig
# TARGET_KERNEL_ARCH := arm64
# TARGET_KERNEL_HEADER_ARCH := arm64
# TARGET_KERNEL_CROSS_COMPILE_PREFIX := aarch64-linux-android-

# Partitions (A605FN PIT)
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 3313500160
BOARD_VENDORIMAGE_PARTITION_SIZE := 503316480
BOARD_ODMIMAGE_PARTITION_SIZE := 377487360
BOARD_CACHEIMAGE_PARTITION_SIZE := 314572800

# VINTF: the manifest/matrix of the stock vendor (target-level 2) so the build-time check sees what the vendor provides
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(DEVICE_PATH)/compatibility_matrix.xml

# Display (panel Samsung S6E3FA7 FHD, 1080x2220)
TARGET_SCREEN_DENSITY := 420

# Properties specific to this device
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop

# Recovery (the stock recovery partition is replaced by TWRP, see AGENTS.md)
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.qcom

# SELinux
BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy
