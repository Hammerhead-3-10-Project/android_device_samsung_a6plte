# LineageOS 17.1 device tree — Samsung Galaxy A6+ (SM-A605FN, `a6plte`)

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

## Installation (SM-A605FN, stock firmware A605FNXXU8CVA1, bootloader unlocked)

The ROM is "system-only": vendor, modem and bootloader stay the stock Samsung ones, so the phone must be on that
firmware (Android 10) before flashing. **All data is lost** (the stock userdata is Samsung FDE, Lineage cannot read it).

1. Flash the TWRP 9.0 for a6plte in Download mode (`heimdall flash --RECOVERY twrp.img --no-reboot`, or Odin/AP).
   Boot it with Vol Up + Power right after (do not let the phone boot Android first, it would restore the stock recovery).
2. In TWRP: **Wipe -> Format Data -> yes**.
3. **Install** the ROM zip. It flashes `system` and a boot image with **dm-verity disabled** (the stock kernel with
   `verify` removed from the dtbs) and, from the recovery, switches the vendor fstab from `forceencrypt` to
   `encryptable` (otherwise the first boot never completes, see `install/patch_vendor.sh`).
4. Reboot system. The first boot takes a few minutes.

The same dm-verity-free boot image is also published on its own (`a6plte-boot-noverity.img`, built as `boot.img`):
TWRP -> Install -> Install Image -> Boot, or `heimdall flash --BOOT`. dm-verity must be off whenever `system`,
`vendor` or `odm` are modified, TWRP included: TWRP mounts them read-write and the next stock boot panics with
`dmv corrupt`.

Not possible / not done: re-locking the bootloader, Knox (warranty bit is tripped for good), encryption of /data.
