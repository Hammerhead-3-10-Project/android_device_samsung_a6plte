#
# Copyright (C) 2026 The PixelExperience Project
# SPDX-License-Identifier: Apache-2.0
#

# Select both app ABIs before core_minimal chooses the default zygote.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Native ARM64 GApps; ARM32 runtime remains available for stock services.
TARGET_GAPPS_ARCH := arm64

# Inherit some common Pixel Experience stuff.
$(call inherit-product, vendor/aosp/config/common_full_phone.mk)

# Inherit from a6plte device
$(call inherit-product, $(LOCAL_PATH)/device.mk)

PRODUCT_BRAND := samsung
PRODUCT_DEVICE := a6plte
PRODUCT_MANUFACTURER := samsung
PRODUCT_MODEL := SM-A605FN
PRODUCT_NAME := aosp_a6plte

PRODUCT_GMS_CLIENTID_BASE := android-samsung

# Boot animation resolution (1080x2220 panel)
TARGET_BOOT_ANIMATION_RES := 1080

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="a6pltexx-user 10 QP1A.190711.020 A605FNXXU8CVA1 release-keys"

BUILD_FINGERPRINT := samsung/a6pltexx/a6plte:10/QP1A.190711.020/A605FNXXU8CVA1:user/release-keys
