# A6+ ARM64 userspace migration

## Target agreed on 2026-10-18

Build Pixel Experience 10 with native ARM64 framework, system services and application support on the
existing ARM64 4.9 kernel. Keep the ARM32 runtime only for necessary components which cannot yet be
replaced. Optional, incompatible components may be omitted after checking their consumers; hardware
services must not be removed merely because their executable is 32-bit.

The current `pe-ten` product remains the tested ARM32 baseline. This document records the migration;
it does not change the architecture of that product or make the current vendor suitable for ARM64.

## Implementation status

The `pe-ten-arm64` branches now implement the initial runtime/graphics/media configuration.
See [ARM64_STATUS.md](ARM64_STATUS.md) for the actual build/check results; the baseline and initial
plan below are retained as design context.

## Verified baseline

- Kernel: 4.9.319, source commit `189707d91ee5867f226505aac11632f3dd9c1ede`, ARM64 and CONFIG_COMPAT=y.
- Stock A605FNXXU8CVA1 vendor: 2,130 regular ELF files, all ELF32; no `lib64` directory.
- `msm8953-common/BoardConfigCommon.mk` selects `TARGET_ARCH := arm`.
- `aosp_a6plte.mk` selects ARM GApps; common product explicitly adds `SetupWizardPrebuiltArm`.
- Generated vendor properties contain `ro.zygote=zygote32`. A migration must also change the generator
  or a subsequent stock regeneration will silently restore that property.
- Stock VINTF declares mapper 2.1 and RenderScript 1.0 as passthrough `32+64` despite having no ARM64
  implementations. The declaration alone does not establish ARM64 support.
- A6+ camera provider, OMX service, fingerprint service and RIL libraries are ELF32.

## Architecture boundary

Binderized services can retain their own ARM32 executables and complete ARM32 dependencies while
serving ARM64 framework clients. Camera tuning, RIL/modem, Trustonic/QSEE and fingerprint are initially
retained from A6+. Cross-architecture IPC still needs functional testing, including vendor extensions
and shared buffers; working ARM32 services do not prove those paths work with ARM64 clients.

EGL/GLES/Vulkan and mapper are loaded inside their clients. ARM64 applications and SurfaceFlinger
need actual AArch64 implementations and their complete matching dependencies. Keeping a 32-bit
composer service does not remove this requirement. Gralloc, mapper, allocator and composer must agree
on buffer handles, formats and metadata; mixing individual libraries without checking that contract
can prevent graphics initialization.

RenderScript needs an ARM64 implementation or a verified source/software fallback and matching
configuration. Do not leave `OVERRIDE_RS_DRIVER := libRSDriver_adreno.so` pointing at an absent ARM64
library. OMX codecs can initially remain behind the existing ARM32 service; a donor codec replacement
is a separate VIDC ABI/firmware task, not a prerequisite solely because applications become ARM64.

## Donor investigation

Repository references were pinned on 2026-10-18. A branch name is not proof of stock firmware origin.

| Candidate | Pinned commit | Findings |
|---|---|---|
| `Saksham033/vendor_xiaomi_daisy`, `q` | `ef03e55fd39c322ae06e011ded4546b5c6ddbe16` | Actual AArch64 EGL, GLESv2, GSL and Vulkan samples inspected with readelf. Exact firmware provenance remains unconfirmed. |
| `mahajant99/vendor_xiaomi_daisy`, `lineage-17.1` | `d8a030843e5ba6efc9891bc411310877dc810c1a` | Tree contains ARM64 graphics candidates under msm8953-common; binary compatibility not checked. |
| `GalaxyA20s/vendor_samsung_a20s`, `main` | `c708f666ab857d8c6ba1f1673715defa3a5fb3e8` | Has lib64, mapper 2.0 and gralloc. build.prop identifies A207MUBS4CWF1, Android 11/API30, patch 2023-05-01: this is not the proposed Android 10 donor. |

Four daisy samples are isolated on the source SSD under `blob-donors/daisy-q-ef03e55`, outside every
build/vendor tree. Their Git blob IDs and sizes were verified against the pinned GitHub tree, then
SHA256 recorded. They are investigation inputs, not an installable vendor set.

The samples already require `libadreno_utils.so` (actual lowercase name), `libllvm-glnext.so`, `libgsl.so`
and matching ARM64 system/vendor dependencies. No assumption is made that these symbols, linker
namespaces, KGSL ioctls or ION allocation interfaces match our kernel. Using the same GPU model does
not establish that contract or guarantee removal of KGSL compatibility patches or reduced UI lag.

Do not transplant donor thermal configuration, power limits or modem/TEE firmware as part of the
architecture migration. Keep A6+ thermal control until a separately justified change is tested.

## A20s Android 11 follow-up (2026-10-18)

The user explicitly includes Android 11 donors. A20s is an active candidate: a different Android
release alone neither rejects a blob nor proves it will run. The vendor repository now tracks
`donors/a20s-gpu.json` and its fetcher, selecting 26 GPU/compiler files across both ABIs. Files are
still isolated on the SSD; the current vendor image and product architecture are unchanged.

The initial audit expanded to 51 downloaded files (49 ELF, two thermal text files), with 2,651
explicit versioned platform imports checked. The GPU subset's 1,730 imports all occur in the Android 10
ARM/ARM64 libc/libdl/libm/liblog export maps. Unversioned dependencies and runtime loading remain open.
A20s reference kernel e8bedc92132230962d4bbaca3af56fdaf67a2a80 has the same KGSL UAPI header as the
local 4.9 kernel; implementation/firmware compatibility still requires validation.

Keep EGL/GLES/Vulkan/GSL consistent: old A6+ GLES/Vulkan import gsl_shared_memory_import, absent from
A20s GSL. Display/metadata, mapper, codecs, perf and thermal have separate dependencies/contracts and
are not selected by the GPU manifest. See vendor `donors/README.md` for the detailed findings,
including the SDM LIBC_R map mismatch and why an export-map mismatch alone is not a complete linker test.

## Remaining subsystem choices (2026-10-18)

An A20s lib64 filename establishes availability, not compatibility. The additional tree inventory
is in project report `a20s-additional-subsystems.json`; these groups have not had the GPU/media ELF audit.

| Subsystem | Preferred first ARM64 approach | Donor checks before replacement |
|---|---|---|
| ION, tinyalsa/tinycompress and common runtime libraries | Build the Android 10 versions for the ABIs used by consumers. | Validate the local kernel UAPI and linker dependencies; do not mix vendor/platform variants by filename. |
| Audio | ARM64 framework can initially use the existing binderized audio/effects 5.0 service with ARM32 vendor dependencies. | A20s has lib64 primary audio and ACDB/calibration libraries; check codec, amplifier, mixer paths, calibration and proprietary Samsung effects before selecting them. |
| Wi-Fi/Bluetooth | Retain functioning stock hardware services; compile suitable Android 10 source components where feasible. | A20s has lib64 Wi-Fi/BT candidates, but chip/transport, driver commands, firmware and configuration must match A6+. |
| GNSS | Keep the stock binderized GNSS path for initial migration. | A20s lists a 2.1 QTI service plus libloc/libgps/libgnss, while the A6+ standard manifest declares 1.0. Verify complete service/QMI dependencies and exported interfaces; filenames are insufficient. |
| Lights/vibrator/power/memtrack/health | Consider small ARM64 source HALs backed by verified A6+ kernel interfaces; retain existing services until implemented. | A20s health 2.1 and Samsung vibrator 2.2 differ from current standard contracts. Preserve brightness, battery charging/thermal behavior and suspend control. |
| DRM | Build Android 10 ClearKey from source; keep A6+ Widevine/OEMCrypto and secure-world integration in their working process ABI. | A20s DRM 1.3 and OEMCrypto are not validated against A6+ keys/trustlets/secure buffers. A generic donor copy does not establish DRM operation or security level. |

These are independent migration tasks. Prioritize graphics and platform runtime, then media; replacing
every binderized HAL before the first ARM64 framework build is not necessary. Core libraries such as
libc, libdl, libhidlbase and libbinder come from the Android 10 build, not wholesale from the Android 11
vendor. No additional hardware-service transplant has been enabled by this inventory.

## Implementation order

1. Confirm the stock firmware origin of a donor and assemble a coherent graphics package for both
   ABIs, including the mapper/gralloc source or blobs it expects. Compare DT_NEEDED, exported/imported
   symbols, Android/VNDK requirements, buffer ABI, KGSL/ION UAPI and required firmware.
2. Prepare an experimental ARM64 product/branch, preserving the current booted ARM32 product and
   rollback. Use a separate output directory so ARM32 and ARM64 intermediate files cannot be mixed.
3. Select `TARGET_ARCH=arm64`, ARMv8-A/cortex-a53 and ARM64 ABI, plus ARM32 `TARGET_2ND_*`. Inherit
   `core_64_bit.mk` before the base product, use `zygote64_32`, ARM64 GApps and the corresponding
   SetupWizard. Remove conflicting generated vendor architecture/zygote properties at their source.
4. Install ARM64 graphics and matching 32-bit support. Validate RenderScript, stock ARM32 service
   dependencies, runtime policy and VINTF against actual installed files. Do not advertise missing HALs.
5. Resolve optional proprietary features individually: replace with compatible/source implementations,
   retain isolated ARM32 services, or remove both feature and consumers when dispensable. Do not
   delete dependencies solely to make the build pass.
6. Check the real boot/system/vendor images, ELF/linker closure, SELinux and partition sizes. System
   is fixed at 3,313,500,160 bytes; vendor at 503,316,480 bytes. Dual-ABI libraries and GApps must fit
   without repartitioning. Offline checks cannot certify a successful first ARM64 boot.
7. Only then arrange the explicitly authorized device test with verified rollback and remote recovery
   constraints. No experimental image has been flashed for this migration.

## Evidence

Host reports in the project directory: `reports/arm64-migration-20261018/` contain stock ELF counts,
passthrough manifest entries, dependency lists, pinned donor trees, A20s build.prop and sample hashes.
No full ROM build or device modification was performed for this investigation.

Architecture reference: [AOSP HIDL](https://source.android.com/docs/core/architecture/hidl) distinguishes
binderized services from passthrough libraries loaded into the client process. AOSP's
[OpenGL ES implementation guide](https://source.android.com/docs/core/graphics/implement-opengl-es)
documents separate `/vendor/lib/egl` and `/vendor/lib64/egl` driver paths.
