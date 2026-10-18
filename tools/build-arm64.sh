#!/usr/bin/env bash
# Build/inspect experimental ARM64 trees with a separate output directory.
# Default target is "nothing" (configuration only); full ROM builds are user-run.
set -euo pipefail
source_tree="${PIXEL_TREE:-/run/media/fenixdev/sorgenti/pixel10}"
port_work="${ARM64_WORK:-/run/media/fenixdev/sorgenti/arm64-port}"
output_dir="${ARM64_OUT_DIR:-out-arm64}"
if [[ "$output_dir" = out || "$output_dir" = /* || "$output_dir" = *..* ]]; then
    echo 'Use a separate relative ARM64_OUT_DIR (default: out-arm64).' >&2
    exit 1
fi
mounts=()
for component in device_samsung_a6plte device_samsung_msm8953-common vendor_samsung_a6plte; do
    component_tree="$port_work/$component"
    [[ "$(git -C "$component_tree" branch --show-current)" = pe-ten-arm64 ]] || {
        echo "Expected pe-ten-arm64 worktree: $component_tree" >&2; exit 1;
    }
    case "$component" in
        device_samsung_a6plte) target_path=device/samsung/a6plte ;;
        device_samsung_msm8953-common) target_path=device/samsung/msm8953-common ;;
        vendor_samsung_a6plte) target_path=vendor/samsung/a6plte ;;
    esac
    mounts+=(-v "$component_tree:/src/$target_path:ro")
    common_git_dir="$(git -C "$component_tree" rev-parse --path-format=absolute --git-common-dir)"
    mounts+=(-v "$common_git_dir:$common_git_dir:ro")
done
mkdir -p "$source_tree/$output_dir"
[[ $# -gt 0 ]] || set -- nothing
exec podman run --rm --userns=keep-id --hostname a6plte-arm64-builder \
    -e HOME=/tmp -e LC_ALL=C -e BUILD_HOSTNAME=a6plte-arm64-builder -e BUILD_NUMBER=arm64-dev \
    -e OUT_DIR="$output_dir" -e ALLOW_MISSING_DEPENDENCIES=true \
    -v "$source_tree:/src:Z" -v "$port_work:$port_work:ro" \
    "${mounts[@]}" -w /src lineage17-builder bash -c '
        set +e; source build/envsetup.sh >/dev/null; set -e
        lunch aosp_a6plte-userdebug
        if [[ "$1" = --config ]]; then
            build/soong/soong_ui.bash --dumpvars-mode --vars="TARGET_ARCH TARGET_ARCH_VARIANT TARGET_CPU_ABI TARGET_2ND_ARCH TARGET_2ND_CPU_ABI TARGET_KERNEL_CONFIG TARGET_KERNEL_CLANG_VERSION TARGET_GAPPS_ARCH PRODUCT_OUT PRODUCT_DEFAULT_PROPERTY_OVERRIDES"
            get_build_var PRODUCT_PACKAGES | tr " " "\n" | sed -n "/SetupWizard/p"
        elif [[ "$1" = --elf-checks ]]; then
            m a6plte-arm64-elf-checks a6plte-runtime-policy -j8
        else
            m "$@" -j8
        fi
    ' _ "$@"
