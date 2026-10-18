# LineageOS 17.1 device tree — Samsung Galaxy A6+ (SM-A605FN, `a6plte`)

## Current `pe-ten` branch (2026-10-18)

This branch builds Pixel Experience 10 with a 32-bit userspace and an ARM64 kernel.
`kernel-profile.mk` selects a matching defconfig and toolchain from the kernel source Makefile:

| Sources | Defconfig | Compiler |
|---|---|---|
| 4.9 (`a6plte-4.9`) | `a6plte_bringup_defconfig` | clang-r353983d, GCC binutils |
| 3.18 (`lineage-17.1`) | `a6plte_sea_open_defconfig` | GCC 4.9, `KCFLAGS=-mno-android` |

Missing configs and other kernel versions stop the build configuration. Selecting a profile does not validate boot.
The project's `scripts/pixel-update-trees.sh --check` checks committed source/destination repositories without
updating them. Run without `--check` to align the trees; `KERNEL_BRANCH=lineage-17.1` selects the 3.18 fallback.
The updater refuses dirty repositories, unexpected origins/branches, unpublished local commits and an active Soong
build lock. Save reviewed changes as commits before using it: uncommitted working-tree edits are never copied.
It preserves the other kernel branch and switches config/compiler automatically on the next configuration pass.
Do not run `repo sync` or edit the trees concurrently. Multi-repository updates are not atomic against power loss.

The initial Lineage bring-up notes below are historical; the current ROM builds boot, system and vendor.

SDM450 (`msm8953`), 2.8 GB RAM, 1080x2220 AMOLED, kernel 3.18.124 arm64 with a **32-bit only userspace**.

## Strategy (Treble, system-only first)
The stock partitions `vendor` (Android 10, VNDK 29), `odm`, `boot` and the bootloader are **kept**. Only the Lineage
`system` image is built here. This avoids rebuilding the Qualcomm/Samsung HALs, the RIL and the camera.

1. **Step 1 (this tree):** `mka systemimage`, flash `system.img` with TWRP/heimdall, keep the stock boot
   (patched with Magisk `KEEPVERITY=false`, see `AGENTS.md`).
2. **Step 2:** source kernel (`kernel/samsung/a6plte`, branch `lineage-17.1`, defconfig `a6plte_sea_open_defconfig`
   with `CONFIG_MACH_A6PLTE_EUR_OPEN=y`) — uncomment the kernel block in `BoardConfig.mk`.
3. **Step 3:** vendor from source if the stock vendor is not enough.

## Data used (stock A605FNXXU8CVA1)
- Partition sizes from the PIT (`A6PLTE_EUR_OPEN.pit`): system 3313500160, vendor 503316480, odm 377487360, boot/recovery 32 MiB.
- Boot header: base 0x80000000, kernel 0x8000, ramdisk 0x2000000, tags 0x1e00000, header v0, pagesize 2048.
- `manifest.xml` and `compatibility_matrix.xml` are the **stock vendor** ones (`target-level` 2): the build-time VINTF
  check must see what the vendor really provides.
- The platform part lives in `device/samsung/msm8953-common` (board config, product config, shared properties and the
  `proprietary-files.txt` with the 25 Samsung/Qualcomm system libraries the stock vendor needs, found with `readelf`
  DT_NEEDED minus vendor/VNDK/LLNDK/AOSP). This tree only has what is specific to the A605FN. Extract the blobs with
  `./extract-files.sh /home/fenixdev/Scrivania/progetto/firmware/extracted` (it calls the common script; system-as-root dump).
  A device specific `proprietary-files.txt` can be added here later (it is picked up automatically).
- Lineage 17.1 maps `msm8953` to `QCOM_HARDWARE_VARIANT := msm8996` (`hardware/qcom-caf/msm8996/{audio,display,media}`).

## Known risks / TODO
- RIL: the stock vendor uses Samsung `libsec-ril` plus `vendor.samsung.hardware.radio@2.0`; Lineage 17.1 telephony may
  need a shim (radio HAL versions, `vendor.samsung.hardware.radio.*` interfaces). Calls/data are the biggest unknown.
- Fingerprint (Samsung `ISehBiometricsFingerprint@3.0`), NFC (`sec.android.hardware.nfc@1.2`), camera
  (`vendor.samsung.hardware.camera.provider@3.0`) and `SamsungServiceMode` need testing.
- `rootdir/etc/fstab.qcom` is a copy of the stock vendor fstab, used for the recovery fstab placeholder only.
- The stock boot keeps `dm-verity` disabled in the device tree; keep it that way (Lineage system is not verity-signed).
- sepolicy dir is empty: expect AVC denials to fix after the first boot (`adb logcat | grep avc`).

## Installation (SM-A605FN, bootloader unlocked)

The zip installs everything the phone needs from the ROM side: `boot` (kernel built from source, dm-verity off),
`system` and `vendor` (built from `vendor/samsung/a6plte`, the stock vendor of A605FNXXU8CVA1 with the
changes listed there). Bootloader, modem and the other firmware partitions stay the stock ones: the phone must be on
Android 10 firmware (U8) before flashing. **All data is lost.**

1. Flash the TWRP 9.0 for a6plte in Download mode (`heimdall flash --RECOVERY twrp.img --no-reboot`, or Odin/AP) and
   boot it with Vol Up + Power right after.
2. In TWRP: **Wipe -> Format Data -> yes**.
3. **Install** the ROM zip, reboot system. The first boot takes a few minutes.

dm-verity is disabled in the device tree of the kernel (`msm8953.dtsi`), so system, vendor and odm can be modified
(and mounted read-write by TWRP) without the next boot panicking with `dmv corrupt`.

Not possible / not done: re-locking the bootloader, Knox (the warranty bit is tripped for good), encryption of /data.
