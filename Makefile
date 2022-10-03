#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright 2019, Joyent, Inc.
# Copyright 2022 MNX Cloud, Inc.
#

#
# LogArchiver Makefile
#

NAME		:=logarchiver

#
# Configuration used by Makefile.defs and Makefile.targ to generate
# "check" and "docs" targets.
#
JSON_FILES	= package.json

#
# Makefile.defs defines variables used as part of the build process.
#

ifeq ($(shell uname -s),SunOS)
	NODE_PREBUILT_VERSION =	v6.17.1
	# minimal-64-lts@21.4.0
	NODE_PREBUILT_IMAGE=a7199134-7e94-11ec-be67-db6f482136c2
	NODE_PREBUILT_TAG := zone64
else
	NPM=npm
	NODE=node
	NPM_EXEC=$(shell which npm)
	NODE_EXEC=$(shell which node)
endif

ENGBLD_USE_BUILDIMAGE	= true
ENGBLD_REQUIRE		:= $(shell git submodule update --init deps/eng)
include ./deps/eng/tools/mk/Makefile.defs
TOP ?= $(error Unable to access eng.git submodule Makefiles.)

BUILD_PLATFORM  = 20210826T002459Z

ifeq ($(shell uname -s),SunOS)
	include ./deps/eng/tools/mk/Makefile.node_prebuilt.defs
	include ./deps/eng/tools/mk/Makefile.agent_prebuilt.defs
endif
include ./deps/eng/tools/mk/Makefile.smf.defs
include ./deps/eng/tools/mk/Makefile.node_modules.defs

ROOT		:= $(shell pwd)
RELEASE_TARBALL	:= $(NAME)-pkg-$(STAMP).tar.gz
RELSTAGEDIR	:= /tmp/$(NAME)-$(STAMP)
DISTCLEAN_FILES += $(RELEASE_TARBALL)

# triton-origin-multiarch-21.4.0
BASE_IMAGE_UUID = 502eeef2-8267-489f-b19c-a206906f57ef
BUILDIMAGE_NAME = $(NAME)
BUILDIMAGE_DESC = Triton LogArchiver
AGENTS		= config registrar

PATH		:= $(NODE_INSTALL)/bin:/opt/local/bin:${PATH}

#
# Repo-specific targets
#
.PHONY: all
all: $(STAMP_NODE_PREBUILT) $(STAMP_NODE_MODULES) $(NPM_EXEC) sdc-scripts

CLEAN_FILES += ./node_modules/tape

#
# Packaging targets
#

.PHONY: hermes
hermes:
	git submodule update --init deps/hermes
	cd deps/hermes && make install DESTDIR=$(TOP)/build/hermes

.PHONY: release
release: all hermes
	@echo "Building $(RELEASE_TARBALL)"
	@mkdir -p $(RELSTAGEDIR)/site
	@touch $(RELSTAGEDIR)/site/.do-not-delete-me
	@mkdir -p $(RELSTAGEDIR)/root/opt/smartdc/boot
	cp -R $(ROOT)/deps/sdc-scripts/* $(RELSTAGEDIR)/root/opt/smartdc/boot
	cp -R $(ROOT)/boot/* $(RELSTAGEDIR)/root/opt/smartdc/boot
	cp -R $(TOP)/build/hermes/opt/smartdc/hermes \
		$(RELSTAGEDIR)/root/opt/smartdc/hermes
	@mkdir -p $(RELSTAGEDIR)/root/opt/smartdc/hermes/etc
	cp $(TOP)/etc/logsets.json \
		$(RELSTAGEDIR)/root/opt/smartdc/hermes/etc
	cp -R $(ROOT)/build \
		$(RELSTAGEDIR)/root/opt/smartdc/hermes/
	@rm -rf $(RELSTAGEDIR)/root/opt/smartdc/hermes/build/hermes
	(cd $(RELSTAGEDIR) && $(TAR) -I pigz -cf $(ROOT)/$(RELEASE_TARBALL) root site)
	@rm -rf $(RELSTAGEDIR)

.PHONY: publish
publish: release
	@if [[ -z "$(ENGBLD_BITS_DIR)" ]]; then \
	  echo "error: 'ENGBLD_BITS_DIR' must be set for 'publish' target"; \
	  exit 1; \
	fi
	mkdir -p $(ENGBLD_BITS_DIR)/$(NAME)
	cp $(ROOT)/$(RELEASE_TARBALL) $(ENGBLD_BITS_DIR)/$(NAME)/$(RELEASE_TARBALL)

#
# Target definitions.  This is where we include the target Makefiles for
# the "defs" Makefiles we included above.
#

include ./deps/eng/tools/mk/Makefile.deps

ifeq ($(shell uname -s),SunOS)
	include ./deps/eng/tools/mk/Makefile.node_prebuilt.targ
	include ./deps/eng/tools/mk/Makefile.agent_prebuilt.targ
endif
include ./deps/eng/tools/mk/Makefile.smf.targ
include ./deps/eng/tools/mk/Makefile.targ
include ./deps/eng/tools/mk/Makefile.node_modules.targ

sdc-scripts: deps/sdc-scripts/.git
