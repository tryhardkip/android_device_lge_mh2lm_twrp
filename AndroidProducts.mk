#
# Copyright (C) 2024 The LineageOS Project
# Copyright (C) 2024 TeamWin Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_MAKEFILES += \
    $(LOCAL_DIR)/twrp_mh2lm.mk

COMMON_LUNCH_CHOICES := \
    twrp_mh2lm-user \
    twrp_mh2lm-userdebug \
    twrp_mh2lm-eng
