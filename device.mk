#
# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/samsung/a6plte

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH) \
    hardware/samsung

# Overlays
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# Screen: 1080x2220 @ 420 dpi
TARGET_SCREEN_HEIGHT := 2220
TARGET_SCREEN_WIDTH := 1080
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xxhdpi


# Samsung hardware (hardware/samsung from the Lineage manifest)
PRODUCT_PACKAGES += \
    SamsungServiceMode

# Vendor-side HALs already shipped by the stock vendor partition are NOT rebuilt here.
# Keep the build time low: this is a system-only device tree for now.

# Inherit the proprietary files (system-side Samsung/Qualcomm libs required by the stock vendor)
$(call inherit-product, vendor/samsung/a6plte/a6plte-vendor.mk)
