#!/usr/bin/make -f
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

# Note: You can override all variables by storing them
# in an external file called "make.conf".
-include conf/make.conf

# Target platform:
# vusolo, bm750, vuuno, vuultimo, vusolo2
#
# This only sets the default value. All platforms now use a shared build
# directory. Run "MACHINE=vuultimo bitbake vuplus-image" to build an image
# for the vuultimo, if it is not the default.
MACHINE ?= vuultimo

MULTI_TEMPORARILY ?= YES

# Adjust according to the number CPU cores to use for parallel build.
# Default: Number of processors in /proc/cpuinfo, if present, or 1.
NR_CPU := $(shell [ -f /proc/cpuinfo ] && grep -c '^processor\s*:' /proc/cpuinfo || echo 1)
BB_NUMBER_THREADS ?= $(NR_CPU)
PARALLEL_MAKE ?= -j $(NR_CPU)

XSUM ?= md5sum

BUILD_DIR = $(CURDIR)/build
TOPDIR = $(BUILD_DIR)/$(MACHINE)
DL_DIR = $(CURDIR)/resource/sources

ifeq ($(MULTI_TEMPORARILY), YES)
SSTATE_DIR = $(TOPDIR)/sstate-cache
TMPDIR = $(TOPDIR)/tmp
DEPDIR = $(TOPDIR)/.deps
else
SSTATE_DIR = $(BUILD_DIR)/sstate-cache
TMPDIR = $(BUILD_DIR)/tmp
DEPDIR = $(BUILD_DIR)/.deps
endif

BBLAYERS ?= \
	$(CURDIR)/meta-bsp/$(MACHINE) \
	$(CURDIR)/meta-bsp/common \
	$(CURDIR)/meta-openvuplus \
	$(CURDIR)/meta-openembedded/meta-oe \
	$(CURDIR)/openembedded-core/meta

CONFFILES = \
	$(TOPDIR)/bitbake.env \
	$(TOPDIR)/conf/bblayers.conf \
	$(TOPDIR)/conf/local.conf

CONFDEPS = \
	$(DEPDIR)/.bitbake.env.$(BITBAKE_ENV_HASH) \
	$(DEPDIR)/.bblayers.conf.$(MACHINE).$(BBLAYERS_CONF_HASH) \
	$(DEPDIR)/.local.conf.$(MACHINE).$(LOCAL_CONF_HASH)

GIT ?= git
GIT_REMOTE := $(shell $(GIT) remote)
GIT_USER_NAME := $(shell $(GIT) config user.name)
GIT_USER_EMAIL := $(shell $(GIT) config user.email)

hash = $(shell echo $(1) | $(XSUM) | awk '{print $$1}')

.DEFAULT_GOAL := all
all: init usage

$(BBLAYERS):
	[ -d $@ ] || $(MAKE) $(MFLAGS) update

init: $(BBLAYERS) $(CONFFILES)

help:
	@echo "Your options:"
	@echo
	@echo "  * Update the SDK"
	@echo "      $$ $(MAKE) update"
	@echo
	@echo "  * Select a new target machine:"
	@echo "      $$ echo MACHINE=vuultimo >> conf/make.conf"
	@echo "    [Valid values: vusolo, bm750, vuuno, vuultimo, vusolo2]"
	@echo
	@echo "  * Build a firmware image for the selected target machine:"
	@echo "      $$ $(MAKE) image"
	@echo
	@echo "  * Build a firmware image for a different target machine:"
	@echo "      $$ $(MAKE) image MACHINE=vuultimo"
	@echo "    [Valid values: vusolo, bm750, vuuno, vuultimo, vusolo2]"
	@echo
	@echo "  * Download all source files at once:"
	@echo "      $$ $(MAKE) download"
	@echo
	@echo "  * Set up the environment to build recipes manually:"
	@echo "      $$ cd $(BUILD_DIR)"
	@echo "      $$ source bitbake.env"
	@echo "      $$ bitbake <target>"
	@echo "    [Replace <target> with a recipe name, e.g. vuplus-image or enigma2]"
	@echo
	@echo "Your current settings:"
	@echo "  MACHINE = $(MACHINE)"
	@echo
	@echo "  BB_NUMBER_THREADS = $(BB_NUMBER_THREADS)"
	@echo "  PARALLEL_MAKE = $(PARALLEL_MAKE)"
	@echo
	@echo "Trouble finding a recipe? Try ./scripts/drepo grep 'search string'"
	@echo "or ./scripts/drepo find -name \"*recipe*\"."
	@echo

usage:
	@echo "[*] Please run '$(MAKE) help' to display further information!"

clean:
	@echo '[*] Deleting generated configuration files'
	@$(RM) $(CONFFILES) $(CONFDEPS)

distclean: clean
	@echo '[*] Deleting dependencies directory'
	@$(RM) -r $(DEPDIR)
	@echo '[*] Deleting download directory'
	@$(RM) -r $(DL_DIR)
	@echo '[*] Deleting tmp directory'
	@$(RM) -r $(TMPDIR)
	@echo '[*] Deleting sstate directory'
	@$(RM) -r $(SSTATE_DIR)
	@echo '[*] Deleting build directory'
	@$(RM) -r $(BUILD_DIR)
	@echo '[*] Deleting git submodules'
	@$(GIT) submodule foreach 'rm -rf .* * 2>/dev/null || true'

image: init
	@echo '[*] Building image for $(MACHINE)'
	@. $(TOPDIR)/bitbake.env && cd $(TOPDIR) && bitbake vuplus-image

download: init
	@echo '[*] Downloading sources'
	@. $(TOPDIR)/bitbake.env && cd $(TOPDIR) && bitbake -cfetchall -k vuplus-image

update:
	@echo '[*] Updating Git repositories...'
	@HASH=`$(XSUM) $(MAKEFILE_LIST)`; \
	if [ -n "$(GIT_REMOTE)" ]; then \
		$(GIT) pull --ff-only || $(GIT) pull --rebase; \
	fi; \
	if [ "$$HASH" != "`$(XSUM) $(MAKEFILE_LIST)`" ]; then \
		echo '[*] Makefile changed. Restarting...'; \
		$(MAKE) $(MFLAGS) --no-print-directory $(MAKECMDGOALS); \
	else \
		$(GIT) submodule sync && \
		$(GIT) submodule update --init && \
		echo "[*] The Vuplus SDK is now up-to-date."; \
	fi

.PHONY: all clean help image init update usage

MACHINE_INCLUDE_CONF = $(CURDIR)/conf/$(basename $(@F))-$(MACHINE)-ext.conf
DISTRO_INCLUDE_CONF = $(CURDIR)/conf/$(basename $(@F))-ext.conf

BITBAKE_ENV_HASH := $(call hash, \
	'BITBAKE_ENV_VERSION = "0"' \
	'CURDIR = "$(CURDIR)"' \
	)

$(TOPDIR)/bitbake.env: $(DEPDIR)/.bitbake.env.$(BITBAKE_ENV_HASH)
	@echo '[*] Generating $@'
	@test -d $(@D) || mkdir -p $(@D)
	@echo '# Automatically generated file. Do not edit!' > $@
	@echo 'export PATH=$(CURDIR)/openembedded-core/scripts:$(CURDIR)/bitbake/bin:$${PATH}' >> $@

LOCAL_CONF_HASH := $(call hash, \
	'LOCAL_CONF_VERSION = "0"' \
	'CURDIR = "$(CURDIR)"' \
	'TOPDIR = "$(TOPDIR)"' \
	'MACHINE = "$(MACHINE)"' \
	'OPENVUPLUS_CONF_VERSION = "1"' \
	'CURDIR = "$(CURDIR)"' \
	'BB_NUMBER_THREADS = "$(BB_NUMBER_THREADS)"' \
	'PARALLEL_MAKE = "$(PARALLEL_MAKE)"' \
	'DL_DIR = "$(DL_DIR)"' \
	'SSTATE_DIR = "$(SSTATE_DIR)"' \
	'TMPDIR = "$(TMPDIR)"' \
	)

$(TOPDIR)/conf/local.conf: $(DEPDIR)/.local.conf.$(MACHINE).$(LOCAL_CONF_HASH)
	@echo '[*] Generating $@'
	@test -d $(@D) || mkdir -p $(@D)
	@echo '# Automatically generated file. Do not edit!' > $@
	@echo 'TOPDIR = "$(TOPDIR)"' >> $@
	@echo 'MACHINE = "$(MACHINE)"' >> $@
	@echo 'BB_NUMBER_THREADS = "$(BB_NUMBER_THREADS)"' >> $@
	@echo 'PARALLEL_MAKE = "$(PARALLEL_MAKE)"' >> $@
	@echo 'DL_DIR = "$(DL_DIR)"' >> $@
	@echo 'SSTATE_DIR = "$(SSTATE_DIR)"' >> $@
	@echo 'TMPDIR = "$(TMPDIR)"' >> $@
	@echo 'BB_GENERATE_MIRROR_TARBALLS = "0"' >> $@
	@echo 'BBINCLUDELOGS = "yes"' >> $@
	@echo 'CONF_VERSION = "1"' >> $@
	@echo 'DISTRO = "vuplus"' >> $@
	@echo 'EXTRA_IMAGE_FEATURES = "debug-tweaks"' >> $@
	@echo 'USER_CLASSES = "buildstats"' >> $@
	@echo 'include $(DISTRO_INCLUDE_CONF)' >> $@
	@echo 'include $(MACHINE_INCLUDE_CONF)' >> $@
	@echo 'INHERIT += "rm_work"' >> $@

BBLAYERS_CONF_HASH := $(call hash, \
	'BBLAYERS_CONF_VERSION = "0"' \
	'CURDIR = "$(CURDIR)"' \
	'BBLAYERS = "$(BBLAYERS)"' \
	)

$(TOPDIR)/conf/bblayers.conf: $(DEPDIR)/.bblayers.conf.$(MACHINE).$(BBLAYERS_CONF_HASH)
	@echo '[*] Generating $@'
	@test -d $(@D) || mkdir -p $(@D)
	@echo '# Automatically generated file. Do not edit!' > $@
	@echo 'LCONF_VERSION = "4"' >> $@
	@echo 'BBFILES = ""' >> $@
	@echo 'BBLAYERS = "$(BBLAYERS)"' >> $@
	@echo 'include $(DISTRO_INCLUDE_CONF)' >> $@
	@echo 'include $(MACHINE_INCLUDE_CONF)' >> $@

$(CONFDEPS):
	@test -d $(@D) || mkdir -p $(@D)
	@$(RM) $(basename $@).*
	@touch $@
