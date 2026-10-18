# Match the toolchain and defconfig to the actual source tree, including after a branch switch.
ifeq ($(wildcard $(TARGET_KERNEL_SOURCE)/Makefile),)
$(error Missing kernel Makefile in $(TARGET_KERNEL_SOURCE); run pixel-update-trees.sh first)
endif
A6PLTE_KERNEL_MAJOR := $(strip $(shell sed -n 's/^VERSION[[:space:]]*=[[:space:]]*//p' $(TARGET_KERNEL_SOURCE)/Makefile))
A6PLTE_KERNEL_MINOR := $(strip $(shell sed -n 's/^PATCHLEVEL[[:space:]]*=[[:space:]]*//p' $(TARGET_KERNEL_SOURCE)/Makefile))
A6PLTE_KERNEL_SERIES := $(A6PLTE_KERNEL_MAJOR).$(A6PLTE_KERNEL_MINOR)

ifeq ($(A6PLTE_KERNEL_SERIES),4.9)
TARGET_KERNEL_CONFIG := a6plte_bringup_defconfig
TARGET_KERNEL_CLANG_COMPILE := true
TARGET_KERNEL_CLANG_VERSION := r353983d
TARGET_KERNEL_ADDITIONAL_FLAGS :=
else ifeq ($(A6PLTE_KERNEL_SERIES),3.18)
TARGET_KERNEL_CONFIG := a6plte_sea_open_defconfig
TARGET_KERNEL_CLANG_COMPILE := false
TARGET_KERNEL_CLANG_VERSION :=
TARGET_KERNEL_ADDITIONAL_FLAGS := KCFLAGS=-mno-android
else
$(error Unsupported A6+ kernel series $(A6PLTE_KERNEL_SERIES); expected 4.9 or 3.18)
endif

ifeq ($(wildcard $(TARGET_KERNEL_SOURCE)/arch/arm64/configs/$(TARGET_KERNEL_CONFIG)),)
$(error Missing $(TARGET_KERNEL_CONFIG) in $(TARGET_KERNEL_SOURCE))
endif
