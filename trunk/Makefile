############################################################################
#
# Makefile -- 顶层 uClinux Makefile。
#
# 版权所有 (c) 2001-2004, SnapGear (www.snapgear.com)
# 版权所有 (c) 2001, Lineo
#
############################################################################

# 定义版本包
VERSIONPKG = 1.1

############################################################################
#
# 包含配置文件
#
############################################################################

# 包含用户配置文件
include .config
# 包含版本信息
include versions.inc

############################################################################
#
# 根据配置决定构建目标
#
############################################################################

# 如果配置中没有内核
ifeq ($(CONFIG_WITHOUT_KERNEL),y)
all: tools unpack_trx libc_only libs_only user_only romfs image
else
    # 如果配置中根文件系统在内存中
    ifeq ($(CONFIG_FIRMWARE_TYPE_ROOTFS_IN_RAM),y)
    all: tools modules libc_only libs_only user_only romfs linux image
    else
    all: tools linux libc_only libs_only user_only romfs image
    endif
endif

############################################################################
#
# 核心变量定义
#
############################################################################

# 项目根目录
ROOTDIR            := $(shell pwd)
# 主机编译器
HOSTCC             = gcc
# ROMFS 安装脚本
ROMFSINST          = $(ROOTDIR)/tools/romfs-inst.sh
# TFTP 目录
TFTPDIR            = /tftpboot
# 更新 PATH 环境变量，添加工具目录和 Go 工具链
PATH               := $(PATH):$(ROOTDIR)/tools:$(ROOTDIR)/tools/go/go/bin
# 版本字符串
VERSIONSTR         = $(CONFIG_VENDOR)/$(CONFIG_PRODUCT) Version $(VERSIONPKG)
# Linux 目录
LINUXDIR           = $(CONFIG_LINUXDIR)
# Linux 头文件目录
LINUXINCDIR        = $(ROOTDIR)/$(LINUXDIR)/include
# 镜像目录
IMAGEDIR           = $(ROOTDIR)/images
# ROMFS 目录
ROMFSDIR           = $(ROOTDIR)/romfs
# 阶段目录
STAGEDIR           = $(ROOTDIR)/stage
# 脚本目录
SCRIPTSDIR         = $(ROOTDIR)/config/scripts
# Linux 配置文件
LINUX_CONFIG       = $(ROOTDIR)/$(LINUXDIR)/.config
# 项目配置文件
PROJECT_CONFIG     = $(ROOTDIR)/.config
# sstrip 工具，如果配置中启用了 sstrip
SSTRIP_TOOL        = $(if $(CONFIG_FIRMWARE_PERFORM_SSTRIP),$(ROOTDIR)/tools/sstrip/sstrip)
# unsquashfs 工具
UNSQUASHFS_TOOL    = $(ROOTDIR)/tools/mksquashfs_xz/unsquashfs
# 合并目录
MERGE_DIR          = $(ROOTDIR)/merge
# 合并后的根文件系统目录
MERGE_ROOTFS       = $(MERGE_DIR)/$(CONFIG_FIRMWARE_PRODUCT_ID)/rootfs

# 计算并行编译使用的 CPU 核心数
HOST_NCPU          = $(shell nproc || echo 1)

# 配置使用的 Shell
CONFIG_SHELL       := $(shell if [ -x "$$BASH" ]; then echo $$BASH; \
                           elif [ -x /bin/bash ]; then echo /bin/bash; \
                           else echo sh; fi)

############################################################################
#
# 交叉编译器配置
#
############################################################################

# 如果存在 config.arch 文件
ifeq (config.arch,$(wildcard config.arch))
    # 如果 Make 目标中不包含 _default
    ifeq ($(filter %_default, $(MAKECMDGOALS)),)
        # 包含 arch 配置
        include config.arch
        ARCH_CONFIG = $(ROOTDIR)/config.arch
        export ARCH_CONFIG
    endif
endif

# 如果 LINUXDIR 中包含 "linux-3.4"
ifeq ($(findstring linux-3.4,$(LINUXDIR)),)
    FIRMWARE_KERNEL_VER = "3.4"
    CONFIG_CROSS_COMPILER_ROOT = $(CONFIG_TOOLCHAIN_DIR)/toolchain-3.4.x
    CONFIG_CROSS_COMPILER_PATH = $(CONFIG_CROSS_COMPILER_ROOT)/bin
    KERNEL_HEADERS_PATH = $(CONFIG_CROSS_COMPILER_ROOT)/mipsel-linux-uclibc/sysroot/usr/include
endif

# 根据 SUBARCH 是否定义，设置 MAKEARCH 和 MAKEARCH_KERNEL
ifeq ($(SUBARCH),)
    MAKEARCH = $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)
    MAKEARCH_KERNEL = $(MAKE) ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE)
else
    MAKEARCH = $(MAKE) ARCH=$(SUBARCH) CROSS_COMPILE=$(CROSS_COMPILE)
    MAKEARCH_KERNEL = $(MAKE) ARCH=$(ARCH) SUBARCH=$(SUBARCH) CROSS_COMPILE=$(KERNEL_CROSS_COMPILE)
endif

# 定义需要构建的目录
DIRS = libc libs user

############################################################################
#
# 导出变量
#
############################################################################

export VENDOR PRODUCT HOSTCC CONFIG_SHELL HOST_NCPU SSTRIP_TOOL
export PROJECT_CONFIG LINUX_CONFIG ROOTDIR LINUXDIR ROMFSDIR SCRIPTSDIR
export FIRMWARE_KERNEL_VER VERSIONPKG VERSIONSTR ROMFSINST PATH IMAGEDIR TFTPDIR
export KERNEL_HEADERS_PATH CONFIG_CROSS_COMPILER_ROOT CONFIG_CROSS_COMPILER_PATH
export UNSQUASHFS_TOOL CONFIG_WITHOUT_KERNEL

############################################################################
#
# 定义 Make 目标
#
############################################################################

# 声明伪目标，确保这些目标总是被执行
.PHONY: all tools unpack_trx libc_only libs_only user_only romfs image linux modules modules_install modules_copy bin_copy romfs.subdirs romfs.post image sparse sparseall subdirs dep clean

# 默认目标
all: tools linux libc_only libs_only user_only romfs image

############################################################################
# 工具构建
############################################################################

.PHONY: tools
tools:
	@echo "正在构建工具..."
	$(MAKE) -C tools

# 解压 TRX 文件
.PHONY: unpack_trx
unpack_trx:
	@echo "正在解压 TRX 文件..."
	$(ROOTDIR)/unpack-trx.sh

############################################################################
# 模块构建
############################################################################

.PHONY: modules
modules:
	@echo "正在构建模块..."
	@if [ "$(CONFIG_MODULES)" = "y" ]; then \
		[ -d $(LINUXDIR)/modules ] || mkdir -p $(LINUXDIR)/modules; \
		$(MAKEARCH_KERNEL) -j$(HOST_NCPU) -C $(LINUXDIR) modules; \
	fi

.PHONY: modules_install
modules_install:
	@echo "正在安装模块..."
	@if [ "$(CONFIG_MODULES)" = "y" ]; then \
		[ -d $(ROMFSDIR)/lib/modules ] || mkdir -p $(ROMFSDIR)/lib/modules; \
		$(MAKEARCH_KERNEL) -C $(LINUXDIR) INSTALL_MOD_PATH=$(ROMFSDIR) DEPMOD=$(ROOTDIR)/tools/depmod.sh modules_install; \
	fi

.PHONY: modules_copy
modules_copy:
	@echo "正在复制模块..."
	[ -d $(ROMFSDIR)/lib/modules ] || mkdir -p $(ROMFSDIR)/lib/modules
	cp -rfa $(MERGE_ROOTFS)/lib/modules $(ROMFSDIR)/lib

.PHONY: bin_copy
bin_copy:
	@echo "正在复制二进制文件..."
	@while read -r f; do \
		cp -fP $(MERGE_ROOTFS)/$$f $(ROMFSDIR)/$$f ; \
	done < $(MERGE_DIR)/file_list | grep -v "^#"

############################################################################
# ROMFS 构建
############################################################################

.PHONY: romfs
romfs: romfs.subdirs $(if $(CONFIG_WITHOUT_KERNEL),modules_copy bin_copy,modules_install) romfs.post

.PHONY: romfs.subdirs
romfs.subdirs:
	@echo "正在处理 ROMFS 子目录..."
	@for dir in vendors $(DIRS); do \
		[ ! -d $$dir ] || $(MAKEARCH) -C $$dir romfs || exit 1; \
	done

.PHONY: romfs.post
romfs.post:
	@echo "正在后处理 ROMFS..."
	-find $(ROMFSDIR)/. -name CVS | xargs -r rm -rf
	$(ROOTDIR)/tools/strip-romfs.sh
	$(MAKEARCH) -C vendors romfs.post

############################################################################
# 镜像构建
############################################################################

.PHONY: image
image:
	@echo "正在创建镜像..."
	[ -d $(IMAGEDIR) ] || mkdir -p $(IMAGEDIR)
	$(MAKEARCH) -C vendors image

############################################################################
# Linux 内核构建
############################################################################

.PHONY: linux
linux:
	@echo "正在构建 Linux 内核..."
	$(MAKEARCH_KERNEL) -j$(HOST_NCPU) -C $(LINUXDIR) $(LINUXTARGET) || exit 1
	@if [ -f $(LINUXDIR)/vmlinux ]; then \
		ln -sf $(LINUXDIR)/vmlinux $(LINUXDIR)/linux; \
	fi

.PHONY: sparse sparseall
sparse:
	@echo "正在构建稀疏内核 (C=1)..."
	$(MAKEARCH_KERNEL) -C $(LINUXDIR) C=1 $(LINUXTARGET) || exit 1

sparseall:
	@echo "正在构建稀疏内核 (C=2)..."
	$(MAKEARCH_KERNEL) -C $(LINUXDIR) C=2 $(LINUXTARGET) || exit 1

############################################################################
# 子目录构建
############################################################################

.PHONY: subdirs
subdirs: libs

.PHONY: libs
libs:
	@echo "正在构建库文件..."
	@for dir in $(DIRS); do \
		[ ! -d $$dir ] || $(MAKEARCH) -C $$dir || exit 1; \
	done

############################################################################
# 依赖关系处理
############################################################################

.PHONY: dep
dep:
	@if [ ! -f $(LINUXDIR)/.config ]; then \
		echo "错误: 需要先运行 'make config' 配置" ; \
		exit 1 ; \
	fi
	@echo "正在准备模块依赖..."
	$(MAKEARCH_KERNEL) -C $(LINUXDIR) modules_prepare
	$(MAKEARCH_KERNEL) -C $(LINUXDIR) dep

############################################################################
# 清理构建文件
############################################################################

.PHONY: clean
clean:
	@echo "正在清理构建产物..."
	$(MAKE) clean -C tools
	@for dir in $(DIRS); do \
		[ ! -d $$dir ] || $(MAKEARCH) -C $$dir clean ; \
	done
	$(MAKEARCH_KERNEL) -C $(LINUXDIR) distclean
	rm -rf $(STAGEDIR) $(ROMFSDIR) $(IMAGEDIR) \
	       $(LINUXDIR)/net/ipsec/alg/libaes $(LINUXDIR)/net/ipsec/alg/perlasm \
	       $(LINUXDIR)/arch/mips/ramdisk/*.gz

############################################################################
#
# 模式规则
#
############################################################################

# ROMFS 目标的模式规则
%_romfs:
	@case "$@" in \
		*/*) dir=`expr "$@" : '\([^/]*\)/.*'`; \
		     target=`expr "$@" : '[^/]*/\(.*\)'`; \
		     $(MAKEARCH) -C $$dir $$target ;; \
		*)    $(MAKEARCH) -C $(@:_romfs=) romfs ;; \
	esac

# 仅构建某一模块的模式规则
%_only:
	@case "$@" in \
		*/*) dir=`expr "$@" : '\([^/]*\)/.*'`; \
		     target=`expr "$@" : '[^/]*/\(.*\)'`; \
		     $(MAKEARCH) -C $$dir $$target ;; \
		*)    $(MAKEARCH) -C $(@:_only=) ;; \
	esac

# 清理某一模块的模式规则
%_clean:
	@case "$@" in \
		*/*) dir=`expr "$@" : '\([^/]*\)/.*'`; \
		     target=`expr "$@" : '[^/]*/\(.*\)'`; \
		     $(MAKEARCH) -C $$dir $$target ;; \
		*)    $(MAKEARCH) -C $(@:_clean=) clean ;; \
	esac

############################################################################
# Makefile 结束
############################################################################
