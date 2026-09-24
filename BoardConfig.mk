#
# Copyright (C) 2024 The LineageOS Project
# Copyright (C) 2024 TeamWin Recovery Project
#
# SPDX-License-Identifier: Apache-2.0
#
# TWRP / LineageOS Recovery BoardConfig for LG G8X ThinQ / V50S (mh2lm)
# SoC: Qualcomm Snapdragon 855 (SM8150 / msmnile)
#

DEVICE_PATH := device/lge/mh2lm

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := kryo385

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := kryo385

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := msmnile
TARGET_NO_BOOTLOADER := true
TARGET_BOARD_PLATFORM := msmnile

# Platform
BOARD_VENDOR := lge
BOARD_USES_QCOM_HARDWARE := true

# Display
TARGET_SCREEN_DENSITY := 401

# A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    product \
    system \
    vbmeta \
    vendor

# Kernel
BOARD_BOOT_HEADER_VERSION := 2
BOARD_KERNEL_CMDLINE := androidboot.hardware=qcom androidboot.memcg=1 lpm_levels.sleep_disabled=1 msm_rtb.filter=0x237 service_locator.enable=1 swiotlb=2048 firmware_class.path=/vendor/firmware_mnt/image loop.max_part=7 androidboot.usbcontroller=a600000.dwc3 kpti=off androidboot.init_fatal_reboot_target=recovery androidboot.boot_devices=soc/1d84000.ufshc
BOARD_KERNEL_BASE := 0x00000000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_TAGS_OFFSET := 0x00000100
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x01000000
BOARD_DTB_OFFSET := 0x01f00000
BOARD_KERNEL_IMAGE_NAME := Image.gz
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
TARGET_KERNEL_CLANG_COMPILE := true
TARGET_KERNEL_SOURCE := kernel/lge/sm8150
TARGET_KERNEL_CONFIG := vendor/lineageos_mh2_defconfig
# NOTE: We deliberately do NOT build a separate dtbo.img.
# The CI disables CONFIG_BUILD_ARM64_DT_OVERLAY (the mh2lm panel overlays fail
# to compile), so `make dtbs` emits base qcom/*.dtb (embedded into boot.img via
# BOARD_INCLUDE_DTB_IN_BOOTIMG) but zero *.dtbo files. With
# BOARD_KERNEL_SEPARATED_DTBO the kernel dtbo.img packaging step then runs
# `mkdtboimg.py create ... $(find -name '*.dtbo')` on an empty list and aborts.
# This device is A/B + recovery-as-boot and the installer only dd's boot.img,
# leaving the on-device dtbo partition intact, so no dtbo.img is required.
# BOARD_KERNEL_SEPARATED_DTBO := true
BOARD_MKBOOTIMG_ARGS += --base $(BOARD_KERNEL_BASE) --pagesize $(BOARD_KERNEL_PAGESIZE) --ramdisk_offset $(BOARD_RAMDISK_OFFSET) --tags_offset $(BOARD_KERNEL_TAGS_OFFSET) --kernel_offset $(BOARD_KERNEL_OFFSET) --dtb_offset $(BOARD_DTB_OFFSET) --header_version $(BOARD_BOOT_HEADER_VERSION)

# Uncomment the following two lines and drop the images into prebuilt/
# if you prefer to build with a prebuilt kernel instead of from source.
# TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image.gz
# TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb.img
# BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo.img

# Partitions
BOARD_USES_METADATA_PARTITION := true
BOARD_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_DTBOIMG_PARTITION_SIZE := 25165824
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 4022337536
BOARD_PRODUCTIMAGE_PARTITION_SIZE := 2147483648
BOARD_VENDORIMAGE_PARTITION_SIZE := 1782579200
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_FLASH_BLOCK_SIZE := 262144
TARGET_COPY_OUT_ODM := vendor/odm
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_VENDOR := vendor
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# Recovery (recovery-as-boot A/B device)
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
# BOARD_INCLUDE_RECOVERY_DTBO would make mkbootimg pass --recovery_dtbo, which
# requires a (recovery) dtbo image. We build none (see the dtbo note above), so
# leave it disabled; the bootloader supplies the panel overlay from the
# untouched on-device dtbo partition at boot.
# BOARD_INCLUDE_RECOVERY_DTBO := true
BOARD_USES_RECOVERY_AS_BOOT := true
TARGET_NO_RECOVERY := true
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab
TARGET_RECOVERY_UI_MARGIN_HEIGHT := 90

# Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA2048
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := 1
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1

# Crypto (FBE v2 + metadata encryption)
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := 2099-12-31
PLATFORM_VERSION := 16.0.0
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
BOARD_USES_METADATA_PARTITION := true
TW_USE_FSCRYPT_POLICY := 2
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)

# TWRP Configuration
TW_THEME := portrait_hdpi
TW_EXTRA_LANGUAGES := true
TW_DEFAULT_LANGUAGE := en
RECOVERY_SDCARD_ON_DATA := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TARGET_USE_CUSTOM_LUN_FILE_PATH := /config/usb_gadget/g1/functions/mass_storage.0/lun.%d/file

# TWRP Screen
TW_SCREEN_BLANK_ON_BOOT := true
TW_BRIGHTNESS_PATH := "/sys/class/backlight/panel0-backlight/brightness"
TW_MAX_BRIGHTNESS := 1023
TW_DEFAULT_BRIGHTNESS := 200
TW_EXCLUDE_DEFAULT_USB_INIT := true
TW_USE_TOOLBOX := true

# TWRP Storage / flashing
TW_HAS_MTP := true
TW_NO_SCREEN_TIMEOUT := true
TW_INCLUDE_REPACKTOOLS := true
TW_INCLUDE_RESETPROP := true
TW_INCLUDE_LIBRESETPROP := true
TW_INCLUDE_NTFS_3G := true
TW_NO_BIND_SYSTEM := true

# Debug
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true

# Statusbar padding for the notch
TW_STATUS_ICONS_ALIGN := center
TW_CUSTOM_CPU_TEMP_PATH := "/sys/class/thermal/thermal_zone13/temp"

# Root
TW_INCLUDE_LOGICAL := false
