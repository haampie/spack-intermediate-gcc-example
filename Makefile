# Make sure user config is not picked up.
export SPACK_USER_CONFIG_PATH=$(CURDIR)/.spack
export SPACK_USER_CACHE_PATH=$(CURDIR)/.spack

.SUFFIXES:

.PHONY: all clean

all: gcc-2/generated/env

clean:
	rm -rf gcc-1/spack.mk gcc-1/spack.lock gcc-1/compilers.yaml gcc-1/config.yaml gcc-1/packages.yaml gcc-1/spack.lock gcc-1/generated gcc-1/.spack-env
	rm -rf gcc-2/spack.mk gcc-2/spack.lock gcc-2/compilers.yaml gcc-2/config.yaml gcc-2/packages.yaml gcc-2/spack.lock gcc-2/generated gcc-2/.spack-env

## GCC 1 (start with system compiler)
gcc-1/compilers.yaml:
	SPACK_USER_CONFIG_PATH=gcc-1 spack compiler find --scope=user

gcc-1/config.yaml:
	SPACK_USER_CONFIG_PATH=gcc-1 spack config --scope=user add config:install_tree:root:$(CURDIR)/store-1

gcc-1/packages.yaml:
	SPACK_USER_CONFIG_PATH=gcc-1 spack external find --scope=user perl m4 autoconf automake libtool gawk

gcc-1/spack.lock: gcc-1/spack.yaml gcc-1/config.yaml gcc-1/packages.yaml gcc-1/compilers.yaml
	spack -e gcc-1 concretize --force

gcc-1/spack.mk: gcc-1/spack.lock
	spack -e gcc-1 env depfile --make-target-prefix gcc-1/generated -o $@

# GCC 2 (depend on GCC 1)
gcc-2/compilers.yaml: gcc-1/generated/env
	SPACK_USER_CONFIG_PATH=gcc-2 spack compiler find --scope=user $$(spack -e gcc-1 find --format '{prefix}' gcc)

gcc-2/config.yaml:
	SPACK_USER_CONFIG_PATH=gcc-2 spack config --scope=user add config:install_tree:root:$(CURDIR)/store-2

gcc-2/packages.yaml:
	SPACK_USER_CONFIG_PATH=gcc-2 spack external find --scope=user perl m4 autoconf automake libtool gawk

gcc-2/spack.lock: gcc-2/spack.yaml gcc-2/config.yaml gcc-2/packages.yaml gcc-2/compilers.yaml
	spack -e gcc-2 concretize --force

gcc-2/spack.mk: gcc-2/spack.lock
	spack -e gcc-2 env depfile --make-target-prefix gcc-2/generated -o $@

ifeq (,$(filter clean,$(MAKECMDGOALS)))
include gcc-1/spack.mk
ifneq (,$(wildcard gcc-1/spack.mk))
include gcc-2/spack.mk
endif
endif
