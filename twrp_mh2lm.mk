#
# Copyright (C) 2024 The LineageOS Project
# Copyright (C) 2024 TeamWin Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Release configuration (Android 14+/trunk build systems).
# Harmless on older branches that don't consume it.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)

# Inherit from the device configuration
$(call inherit-product, device/lge/mh2lm_twrp/device.mk)

# Inherit TWRP common stuff
$(call inherit-product, vendor/twrp/config/common.mk)

# Device identifier. This must come after all inclusions.
PRODUCT_NAME := twrp_mh2lm
PRODUCT_DEVICE := mh2lm
PRODUCT_MANUFACTURER := LGE
PRODUCT_BRAND := LGE
PRODUCT_MODEL := G8X ThinQ

PRODUCT_GMS_CLIENTID_BASE := android-lge

PRODUCT_BUILD_PROP_OVERRIDES += \
    DeviceProduct=mh2lm \
    BuildDesc="mh2lm-user 12 SKQ1.211103.001 223331636afae release-keys" \
    BuildFingerprint=lge/mh2lm/mh2lm:12/SKQ1.211103.001/223331636afae:user/release-keys
