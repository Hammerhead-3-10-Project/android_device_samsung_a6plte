# Pixel Experience 10 ARM64 bring-up — 2026-10-18

The `pe-ten-arm64` branches implement a native ARM64 product with ARM32 compatibility. The original
`pe-ten` worktrees and the booted ARM32 ROM remain the reference. ~~No ARM64 ROM image has been flashed.~~
The user installed ARM64 build `3638527e67` on 2026-10-19; complete boot is not yet confirmed.

## Runtime update — 2026-10-19

The first ARM64 attempt starts zygote64, the secondary zygote and system_server, but SurfaceFlinger
waits for configstore. The stock overlay replaced the source-built configstore executable with the
Samsung ARM32 version while the build installed the AOSP ARM64 seccomp policy. Minijail terminates
that process on `fstat64`; changing SELinux or disabling seccomp is not needed to correct this mismatch.

`vendor/arm64/build.mk` now excludes the configstore executable and init rc from the stock overlay,
as it already does for the native allocator/composer services. This selects the Android 10 source
ARM64 configstore and its ARM64 policy. The original ARM32 blob remains in the proprietary inventory.
The installed init rc is byte-identical to the source rc; the installed policy matches AOSP ARM64.

A recovery repair replaced only the executable with the existing compiled ARM64 artifact, SHA256
`24f21e32c4019d07eba0b767b68424ffc7b4477fcaabc8a993d3fa2fb1969685`, preserving its executable label.
Original files are backed up on the PC in `reports/arm64-configstore-20261019/` and on the device
under `/data/local/tmp/a6plte-configstore-20261019/`. Native dependencies were found in vendor/lib64
and system/lib64/vndk-29. A new boot is required to validate runtime behavior. The existing ROM ZIP
has not been rebuilt and still contains the original mismatch.

For diagnostics, the installed vendor USB rc temporarily forces `mtp,adb` and this PC's public key
was added to `/data/misc/adb/adb_keys`. RSA authentication and SELinux remain enabled. This temporary
device-only USB change is not part of the source product or ROM ZIP.

## Implemented

- ARMv8-A/cortex-a53 primary ABI `arm64-v8a`, secondary `armeabi-v7a`/`armeabi`, binder64.
- `core_64_bit.mk`, `zygote64_32`, ARM64 GApps and the original ARM64 SetupWizard.
- Product-generated Bionic/ART architecture properties; stock ARM32 properties are filtered at generation.
- Fifteen A20s AArch64 GPU/compiler/conversion libraries, alongside the unchanged ARM32 proprietary set.
- A tracing bridge for the Android 11 Adreno `atrace_get_enabled_tags` import. Four blobs have an added
  DT_NEEDED entry; executable sections are unchanged. Source/patched hashes and the refresh procedure
  are tracked in vendor `arm64/`.
- Android 10 source gralloc1, mapper 2.1, allocator/composer and media wrappers/helpers. The vendor overlay
  preserves stock ARM32 libraries and services, except the allocator/composer executables/init files,
  which use the source-built ARM64 services. The OMX hardware service/codecs remain ARM32.
- Source RenderScript CPU path selected without the absent Adreno RS64 override. This part has been
  configured but not separately compiled by the targeted graphics checks.
- Explicit ARM32 source runtime dependencies for retained stock vendor files. The list contains 155
  actual ARM shared-library modules; the inventory also records unresolved/optional names requiring a
  later full-image dependency audit.

Kernel sources remain `a6plte-4.9` at `189707d91ee5867f226505aac11632f3dd9c1ede`, using
`a6plte_bringup_defconfig` and clang-r353983d. The existing Samsung first-stage ramdisk is retained;
its static ARM32 init is an intentional compatibility component, not a rebuilt ARM64 binary.

## Isolated build

The project has worktrees under `/run/media/fenixdev/sorgenti/arm64-port/`:

- `device_samsung_a6plte`
- `device_samsung_msm8953-common`
- `vendor_samsung_a6plte`

`tools/build-arm64.sh` mounts these read-only over the existing PE10 checkout inside `lineage17-builder`
and writes only the separate `pixel10/out-arm64` build output. It checks branch names and refuses `out`
as the output directory. No update of the working ARM32 checkout is needed. The project wrapper is
`scripts/pixel-arm64.sh`; the ordinary `scripts/build-pixel.sh` continues selecting the ARM32 trees.

From the project directory:

```sh
bash scripts/pixel-arm64.sh --config       # architecture, GApps and kernel profile
bash scripts/pixel-arm64.sh nothing        # Soong/Kati configuration
bash scripts/pixel-arm64.sh --elf-checks   # real ELF checks plus Samsung runtime policy
bash scripts/pixel-arm64.sh bacon          # full ROM build, to be run by the user
```

`PIXEL_TREE`, `ARM64_WORK` and `ARM64_OUT_DIR` can override the default paths. The corresponding helper
can also be run directly from this device repository. BUILD_HOSTNAME/BUILD_NUMBER are stable development
values to avoid invalidating Kati every time Podman creates a new container.

## Verified offline

- Full Soong/Kati graph generation succeeded.
- ION/TinyALSA/TinyCompress and the native blob targets compiled/installed successfully.
- Gralloc, HWC, mapper, allocator/composer and OMX wrappers/core/conversion targets compiled successfully,
  including their ARM32 variants where configured.
- All fifteen Android ELF-check stamps exist: SONAME, DT_NEEDED and imported symbols checked against
  actual Android 10 ARM64 dependencies. No undefined-symbol exception or disabled ELF check was used.
- The image/overlay rules depend on these ELF checks, including direct vendor image builds.
- Samsung runtime CIL compiles against the new platform policy; complete vendor file contexts and the
  supplementary hardware/property contexts pass the existing validation rule. SELinux was not relaxed.
- Installed blob hashes match the pinned original/fixed hashes. The compatibility library exports only
  `atrace_get_enabled_tags` and implements the real Android 10 inline behavior.
- Generated vendor properties contain `zygote64_32`, Bionic arm64+arm and the correct ABI lists.
- Generator regression tests and a complete stock regeneration roundtrip pass. The ARM32 proprietary
  vendor files are byte-identical to `pe-ten`; new native files are outside the regenerated stock subtree.

Detailed evidence is in project `reports/arm64-port-20261018/`.

## Remaining before a device test

The full ROM, target-files and OTA images still need to be built and checked for partition fit and final
library closure. Partial build directories contain generated ARM32 graphics files until the final vendor
overlay runs; inspect the packaged vendor image, not those temporary files, when checking legacy retention.

Buffer handles/metadata shared between native graphics and legacy camera/media, KGSL/ION runtime behavior,
first-stage init transitioning to ARM64 system init, hardware operation and performance are not validated
by compiling. ARM64 donor encoder/decoder activation is deferred until QSEE/metadata/VIDC dependencies are
resolved. A successful build is not a successful boot. The known NFC configuration and Trustonic follow-up
from the current ROM remain separate issues. Further flashes require a specific device-test decision.

### Configstore repair runtime result — 2026-10-19

The user rebooted after the executable replacement. `sys.boot_completed=1` and bootanimation stopped
were observed on boot ID `53def9c6-067b-45d4-a816-c61bdabbaa97`; configstore and SurfaceFlinger remain
running. The physical display is black. SurfaceFlinger logs repeated Adreno metadata signature 0,
EGLImage error 0x3003 and framebuffer binding failures; KGSL GPUOBJ_IMPORT also returns errno 12.
The donor V502 Adreno stack is loaded, with approximately 2.2 GB available RAM. This is not evidence
of ordinary RAM exhaustion. The current msm8996 source metadata predates the donor's GraphicsMetadata
API. Exact layout compatibility and any independent KGSL/ION issue still require investigation.
No GPU/gralloc changes have been applied for this second failure. Evidence is in project reports
`arm64-boot-20261019-101403-gzuFhS` and `arm64-boot-20261019-101600-noXxOs`.

### Follow-up: unsupported gralloc extension response — 2026-10-19

Before replacing the graphics stack, test a smaller API correction. The existing msm8996
`BufferManager::Perform` returns success for unknown operations without filling their output.
The newer graphics-metadata query is one such unimplemented operation. A caller can mistake the
untouched zero-filled blob for valid metadata. Returning `GRALLOC1_ERROR_UNSUPPORTED` is the correct
response; whether the donor driver can render through its fallback still requires a device test.

The display source now has an isolated `pe-ten-arm64` worktree at
`/run/media/fenixdev/sorgenti/arm64-port/hardware_qcom_display`, based on `8570a04`. The ARM64 launcher
requires and mounts this fourth worktree read-only over `hardware/qcom/display`. The original display
checkout remains unchanged. Only the ARM64 gralloc module is intended for the recovery experiment;
stock ARM32 graphics libraries and the buffer/metadata layouts are preserved.

Reference for the newer extension contract: [AOSP Qualcomm display import](https://android.googlesource.com/platform/hardware/qcom/sdm710/display/+/9aec1a1557310fec18d1972b47b5aa75bb1d5681/gralloc/gralloc_priv.h).
The patch and build evidence are in project `patches/graphics/` and `reports/arm64-gralloc-20261019/`.
A successful compile does not establish that this fixes the black display.

**Source-selection correction before the experiment:** the generated Ninja edge uses
`hardware/qcom-caf/msm8996/display`, not the older PixelExperience `hardware/qcom/display` tree.
The initial unused edit was reverted, with its diff retained in the host report. The actual fourth
worktree is `hardware_qcom_display_msm8996` at `744e84a`, mounted over the CAF display source.
The CAF implementation additionally assigns opcode 16 to the legacy interlace query. The donor
jump table/disassembly assigns 16 to graphics metadata instead. The experiment therefore returns
UNSUPPORTED for opcode 16 on AArch64, preserving the ARM32 interlace behavior, and rejects unknown
operations. No buffer layout change or fabricated metadata is introduced. Runtime fallback remains
unverified. The initial no-work build was not validation of a changed binary.

### Unsupported-extension experiment result — 2026-10-19

The changed CAF gralloc compiled successfully (01:40) and only its ARM64 module was installed in
recovery, SHA256 `07770dd2314a8fcc4e0c5fa6e73d9229e01416e631b81c4069697a951f71181e`. Its DT_NEEDED
set is unchanged, and the installed ARM32 gralloc still matches the stock blob. Original ARM64 module
is backed up under `/data/local/tmp/a6plte-gralloc-unsupported-20261019/` and in the host report.

Boot `723debc8-c926-4e28-91d7-96e04adb7482` reaches boot_completed=1 at approximately 38 seconds.
However, the captured screenshot is black. Bad-metadata signature errors no longer appear in the
recent log sample, but EGLImage still fails with 0x3002, and the live startup stream includes a few
framebuffer failures. Rejecting opcode 16 does not restore rendering. The next implementation must
provide a matching graphics metadata contract, or a fully audited matching gralloc set, rather than
claim success from unsupported responses or boot completion. No further device change was made.
Evidence: project `reports/arm64-boot-20261019-102649-QhDV9G/`, including screen.png and result JSON.
