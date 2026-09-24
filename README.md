# TWRP device tree for LG G8X ThinQ / V50S (mh2lm)

TWRP / LineageOS Recovery device tree for the **LG G8X ThinQ (LM-G850)** and
**LG V50S ThinQ (mh2lm)**, targeting **LineageOS 23.2 / Android 16**.

- SoC: Qualcomm Snapdragon 855 (SM8150 / `msmnile`)
- Codename: `mh2lm`
- Partition layout: A/B, recovery-as-boot (TWRP is flashed to `boot`)
- Encryption: FBE v2 + metadata encryption

Derived from the LineageOS device trees:
- https://github.com/tryhardkip/android_device_lge_mh2lm (branch `lineage-23.2`)
- https://github.com/tryhardkip/android_device_lge_sm8150-common (branch `lineage-23.2`)

## Contents

```
.
├── Android.bp                     # Soong namespace
├── AndroidProducts.mk             # Product/lunch definitions
├── BoardConfig.mk                 # Board + TWRP flags (self-contained)
├── device.mk                      # Product packages / copy files
├── twrp_mh2lm.mk                  # Product definition (twrp_mh2lm)
├── vendorsetup.sh                 # add_lunch_combo entries
├── prebuilt/                      # Optional: drop prebuilt kernel here
└── recovery/root/system/etc/
    ├── recovery.fstab             # TWRP fstab
    └── init/init.recovery.qcom.rc # Recovery ramdisk init
```

This is a **standalone** TWRP tree — it does not depend on the full LineageOS
device tree being present, only on the TWRP minimal manifest plus the kernel
source.

## Building

TWRP for an Android 16 device is built against the TWRP minimal manifest
(`twrp-14.1` branch works for current devices).

1. Sync the minimal manifest:

   ```bash
   mkdir twrp && cd twrp
   repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-14.1
   repo sync -c -j$(nproc --all)
   ```

2. Place this tree at `device/lge/mh2lm`:

   ```bash
   git clone https://github.com/tryhardkip/android_device_lge_mh2lm_twrp.git device/lge/mh2lm
   ```

3. Provide the kernel. This tree builds the kernel from source by default:

   ```bash
   git clone https://github.com/rainbowdashh/android_kernel_lge_sm8150.git kernel/lge/sm8150 -b lineage-23.2
   ```

   This repo/branch provides `arch/arm64/configs/vendor/lineageos_mh2_defconfig`,
   which is what `TARGET_KERNEL_CONFIG` in `BoardConfig.mk` points to.
   Alternatively, drop `Image.gz`, `dtb.img` and `dtbo.img` into `prebuilt/`
   and uncomment the `TARGET_PREBUILT_*` lines in `BoardConfig.mk`.

4. Build:

   ```bash
   source build/envsetup.sh
   lunch twrp_mh2lm-eng
   mka bootimage
   ```

   Because this is a **recovery-as-boot** device, TWRP is packed into the
   **boot image**. The output is:

   ```
   out/target/product/mh2lm/boot.img
   ```

## Building in CI (GitHub Actions)

A workflow is included at `.github/workflows/build.yml`. It syncs the TWRP
minimal manifest, drops in this tree and the kernel source, builds, and uploads
the resulting `boot.img` as an artifact.

Run it from the repo's **Actions** tab → "Build TWRP (mh2lm)" → **Run workflow**.
Inputs let you change the manifest branch, kernel branch, lunch target and make
target without editing the file. A full sync + build on GitHub-hosted runners
takes a while and needs the disk-cleanup step (already included) to fit.

## Flashing

### Flashable zip (from LineageOS recovery or TWRP)

The build/CI also produces `TWRP-mh2lm-<date>.zip`. It's a self-contained
installer (`installer/META-INF/com/google/android/update-binary`, a shell
script) that writes the TWRP `boot.img` to the active A/B slot. Because it
ships its own installer script, it runs in the stock LineageOS recovery
(sideload / install from storage) as well as in TWRP/OrangeFox.

To build the zip locally from an existing `boot.img`:

```bash
tools/mkzip.sh out/target/product/mh2lm/boot.img
```

### fastboot

```bash
# Boot it once without flashing (recommended first):
fastboot boot out/target/product/mh2lm/boot.img

# Or flash to the boot partition (this replaces the OS boot ramdisk; only do
# this on a device where recovery lives in boot):
fastboot flash boot out/target/product/mh2lm/boot.img
```

> ⚠️ This is a recovery-as-boot A/B device. Flashing `boot.img` overwrites the
> current boot ramdisk. Verify the target/slot before flashing, and keep a copy
> of your stock/LineageOS `boot.img` so you can restore it.

## Notes / things to verify on-device

- `recovery.fstab`: the external SD (`mmcblk1p1`) and USB-OTG (`sda`) block
  paths are the common defaults for this platform — confirm against a running
  recovery (`cat /proc/partitions`) and adjust if needed.
- `TW_BRIGHTNESS_PATH` and `TW_CUSTOM_CPU_TEMP_PATH` are taken from the LGE
  init scripts / typical `msmnile` thermal zones; adjust if brightness or the
  temperature readout is wrong.
- Decryption relies on the FBE v2 + metadata-encryption flags in the fstab.
  If decryption fails, confirm the `keydirectory` and encryption options match
  the LineageOS 23.2 `fstab.qcom`.
- Device DT overlays: the CI build disables `CONFIG_BUILD_ARM64_DT_OVERLAY`
  because the kernel's `sm8150-mh2lm` `.dtbo` overlays fail to compile
  (`&soc {` syntax error in `sm8150-mh2lm_common.dtsi`) and abort `make dtbs`.
  The recovery `boot.img` only needs the base SoC `.dtb`; on this A/B +
  separated-DTBO device the bootloader merges the correct overlay from the
  on-device `dtbo` partition (untouched by the `dd` installer) at boot, so no
  `dtbo.img` is produced or flashed. To match this, `BoardConfig.mk` leaves
  `BOARD_KERNEL_SEPARATED_DTBO` and `BOARD_INCLUDE_RECOVERY_DTBO` disabled;
  otherwise the kernel dtbo packaging step (`mkdtboimg.py create` on an empty
  `*.dtbo` list) or `mkbootimg --recovery_dtbo` would fail. If a future kernel
  fixes the overlay DTS, re-enable those two flags and drop the "Disable device
  DT overlays" step in `.github/workflows/build.yml`.
