#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/samsung/a6plte

# Soong namespace
PRODUCT_SOONG_NAMESPACES += $(LOCAL_PATH)

# Overlays
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# Screen: 1080x2220 @ 420 dpi
TARGET_SCREEN_HEIGHT := 2220
TARGET_SCREEN_WIDTH := 1080
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi

# The vendor partition: files, links, SELinux policy and properties of the stock vendor
# A6PLTE_ANALYSIS=1 skips the stock vendor so the ninja files list what the PE tree installs in /vendor
# (input of gen_vendor.py's collision snapshot).
ifndef A6PLTE_ANALYSIS
$(call inherit-product, vendor/samsung/a6plte/a6plte-vendor.mk)
endif

# Common Samsung msm8953 configuration (Treble, hardware/samsung, proprietary system libs)
$(call inherit-product, device/samsung/msm8953-common/msm8953.mk)

# ARM64-only additions, tracked independently of the regenerated stock vendor.
ifndef A6PLTE_ANALYSIS
$(call inherit-product, vendor/samsung/a6plte/arm64/arm64-vendor.mk)
endif
