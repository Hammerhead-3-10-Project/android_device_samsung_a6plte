#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Samsung Galaxy A6+ (SM-A605FN, a6plte) - SDM450 / msm8953, Android 10 stock vendor.
#
# Strategy (see README.md): build only the Lineage `system` on top of the stock `vendor`, `odm` and
# `boot` partitions (Treble). The kernel is the stock one (prebuilt) until a source kernel is wired in.
# Values come from the stock firmware A605FNXXU8CVA1 (PIT, boot header, vendor manifest, getprop).

DEVICE_PATH := device/samsung/a6plte

BOARD_VENDOR := samsung

# Allow building with a minimal tree while the vendor blobs are being sorted out
ALLOW_MISSING_DEPENDENCIES := true

# Architecture: arm64 kernel but a 32-bit only userspace (abilist armeabi-v7a), binder is 64 bit
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := cortex-a53
TARGET_CPU_VARIANT_RUNTIME := cortex-a53

TARGET_USES_64_BIT_BINDER := true

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := msm8953
TARGET_NO_BOOTLOADER := true

# Platform (Lineage 17.1 maps msm8953 to QCOM_HARDWARE_VARIANT := msm8996, UM 3.18 family)
TARGET_BOARD_PLATFORM := msm8953
BOARD_USES_QCOM_HARDWARE := true

# Kernel: stock Image.gz-dtb for now (arm64 Image + 5 appended dtb, header v0)
BOARD_KERNEL_BASE := 0x80000000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x02000000
BOARD_SECOND_OFFSET := 0x00f00000
BOARD_KERNEL_TAGS_OFFSET := 0x01e00000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_BOOT_HEADER_VERSION := 0
BOARD_KERNEL_CMDLINE := console=null androidboot.hardware=qcom msm_rtb.filter=0x237 ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --second_offset $(BOARD_SECOND_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --board SRPQL20D008KU
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image.gz-dtb
# Step 3 (kernel from source, branch lineage-17.1 of the Samsung opensource tree):
# TARGET_KERNEL_SOURCE := kernel/samsung/a6plte
# TARGET_KERNEL_CONFIG := a6plte_sea_open_defconfig
# TARGET_KERNEL_ARCH := arm64
# TARGET_KERNEL_HEADER_ARCH := arm64
# TARGET_KERNEL_CROSS_COMPILE_PREFIX := aarch64-linux-android-

# Partitions (A605FN PIT): no A/B, no dynamic partitions, separate system/vendor/odm
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 3313500160
BOARD_VENDORIMAGE_PARTITION_SIZE := 503316480
BOARD_ODMIMAGE_PARTITION_SIZE := 377487360
BOARD_CACHEIMAGE_PARTITION_SIZE := 314572800
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_ODM := odm
TARGET_USERIMAGES_USE_EXT4 := true
BOARD_HAS_LARGE_FILESYSTEM := true

# The stock system partition is a system-as-root image (init, sepolicy_version... at its root)
BOARD_BUILD_SYSTEM_ROOT_IMAGE := true
BOARD_ROOT_EXTRA_FOLDERS := efs omr preload

# Treble: vendor is Android 10 (VNDK 29), first API level 26
BOARD_VNDK_VERSION := current
PRODUCT_FULL_TREBLE_OVERRIDE := true
PRODUCT_SHIPPING_API_LEVEL := 26

# VINTF: use the manifest/matrix of the stock vendor so the build-time compatibility check passes
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(DEVICE_PATH)/compatibility_matrix.xml

# Display (panel Samsung S6E3FA7 FHD, 1080x2220)
TARGET_SCREEN_DENSITY := 420
TARGET_USES_HWC2 := true
TARGET_USES_ION := true
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3
OVERRIDE_RS_DRIVER := libRSDriver_adreno.so
BOARD_USES_ADRENO := true

# Properties
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop

# Recovery (the stock recovery partition is replaced by TWRP, see README.md)
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.qcom
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"

# Security patch level / SELinux
BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy

# Inherit the proprietary blobs
-include vendor/samsung/a6plte/BoardConfigVendor.mk
