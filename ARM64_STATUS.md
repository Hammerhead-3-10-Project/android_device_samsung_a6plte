# Pixel Experience 10 ARM64 bring-up — 2026-10-18

The `pe-ten-arm64` branches implement a native ARM64 product with ARM32 compatibility. The original
`pe-ten` worktrees and the booted ARM32 ROM remain the reference. No ARM64 ROM image has been flashed.

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
