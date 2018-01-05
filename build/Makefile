
: ${VERBOSE:=0}

VERSION_FILE	= $(shell [ -f "./VERSION" ] && echo "./VERSION" || echo "./../VERSION")
VERSION 			= $(shell sed -e "s/[[:space:]]//g" < $(VERSION_FILE))
PACKAGE_TYPES	= tar deb rpm pacman

#
# Local tasks
#

.PHONY: build
build: build-archive build-packages

.PHONY: build-archive
build-archive:
	@rm -rf ../pkg/archive && mkdir -p ../pkg/archive
	@cp -t ../pkg/archive/ ../COPYING ../LICENSE
	@cp Makefile.dist ../pkg/archive/Makefile
	@cp ../chapecron.conf ../pkg/archive/chapecron.conf
	@mkdir -p ../pkg/archive/plugins.d
	@cp ../plugins.d/*.sh ../pkg/archive/plugins.d/
	@sed -e "s/^.*__PKG__ //; s/__VERSION__/$(VERSION)/" ../chapecron > ../pkg/archive/chapecron
	@chmod 0444 ../pkg/archive/COPYING ../pkg/archive/LICENSE
	@chmod 0644 ../pkg/archive/chapecron.conf ../pkg/archive/plugins.d/*.sh
	@chmod 0755 ../pkg/archive/Makefile ../pkg/archive/chapecron


.PHONY: build-packages
build-packages: $(foreach t, $(PACKAGE_TYPES), build-package-$(strip $(t)))

define PACKAGE_BUILDER_TASK =

.PHONY: build-package-$(strip $(1))-up
build-package-$(strip $(1))-up:
	@vagrant status chapecron-builder-$(strip $(1)) | grep -q running || vagrant up chapecron-builder-$(strip $(1))
endef

$(eval $(foreach t, $(PACKAGE_TYPES), $(call PACKAGE_BUILDER_TASK, $(t))))

define PACKAGE_BUILD_TASK =

.PHONY: build-package-$(strip $(1))
build-package-$(strip $(1)): build-archive build-package-$(strip $(1))-up
	@vagrant ssh chapecron-builder-$(strip $(1)) \
		-c "cd /chapecron/build && make vagrant-build-package-$(strip $(1))"
endef

$(eval $(foreach t, $(PACKAGE_TYPES), $(call PACKAGE_BUILD_TASK, $(t))))

.PHONY: test-packages
test-packages: $(foreach t, $(PACKAGE_TYPES), test-package-$(strip $(t)))

define PACKAGE_TEST_TASK =

.PHONY: test-package-$(strip $(1))
test-package-$(strip $(1)): build-package-$(strip $(1))-up
	@vagrant ssh chapecron-builder-$(strip $(1)) \
		-c "cd /chapecron/build && VERBOSE=$(VERBOSE) make vagrant-test-package-$(strip $(1))"
endef

$(eval $(foreach t, $(PACKAGE_TYPES), $(call PACKAGE_TEST_TASK, $(t))))

#
# Remote tasks
#
PACKAGE_PREFIX		= /usr
PACKAGE_CONFDIR		= /etc/chapecron
PACKAGE_BINDIR		= $(PACKAGE_PREFIX)/bin
PACKAGE_LIBDIR		= $(PACKAGE_PREFIX)/lib/chapecron

# Hooks
HOOKS 						= install remove
HOOK_install_FILE	:= $(shell mktemp /tmp/build-package.XXXXXX)
HOOK_remove_FILE	:= $(shell mktemp /tmp/build-package.XXXXXX)

define HOOK_TASK =

.PHONY: vagrant-hook-$(strip $(1))
vagrant-hook-$(strip $(1)):
	@cat hooks/$(strip $(1)).tpl > $$(HOOK_$(strip $(1))_FILE)
	@sed -i "s@__LIBDIR__@$(PACKAGE_LIBDIR)@g" $$(HOOK_$(strip $(1))_FILE)
	@sed -i "s@__BINDIR__@$(PACKAGE_BINDIR)@g" $$(HOOK_$(strip $(1))_FILE)
	@chmod 700 $$(HOOK_$(strip $(1))_FILE)
endef

$(eval $(foreach h, $(HOOKS), $(call HOOK_TASK, $(h))))

# Packages
define PACKAGE_OPTIONS_COMMON =

	--force
	--chdir ../pkg/

	--name "chapecron"
	--description "chapecron look after your crons while you are away"
	--maintainer "<dev@notus.sh>"
	--url "https://github.com/notus-sh/chapecron"
	--license "CC0-1.0"

	--version "$(VERSION)"
	--iteration 1
	--architecture all

	--provides chapecron
	--config-files "$(PACKAGE_CONFDIR)/chapecron.conf"
	--directories	"$(PACKAGE_CONFDIR)"
	--directories	"$(PACKAGE_LIBDIR)"

	--after-install "$(HOOK_install_FILE)"
	--before-remove "$(HOOK_remove_FILE)"

	--input-type dir

	archive/chapecron.conf="$(PACKAGE_CONFDIR)/"
	archive/plugins.d="$(PACKAGE_LIBDIR)/"
	archive/chapecron="$(PACKAGE_LIBDIR)/"
	archive/COPYING="$(PACKAGE_LIBDIR)/"
	archive/LICENSE="$(PACKAGE_LIBDIR)/"
endef

define PACKAGE_OPTIONS_TAR =
	--package ../pkg/chapecron-$(VERSION).tar
endef
PACKAGE_OPTIONS_tar = $(strip $(PACKAGE_OPTIONS_TAR))

define PACKAGE_OPTIONS_DEB =
	--package ../pkg/
	--exclude Makefile
	--deb-no-default-config-files
	--depends "bash (>=4.0.0)"
	--depends "util-linux (>=1.0.0)"
endef
PACKAGE_OPTIONS_deb = $(strip $(PACKAGE_OPTIONS_DEB))

define PACKAGE_OPTIONS_RPM =
	--package ../pkg/
	--exclude Makefile
	--depends "bash >= 4.0.0"
	--depends "util-linux >= 1.0.0"
endef
PACKAGE_OPTIONS_rpm = $(strip $(PACKAGE_OPTIONS_RPM))

define PACKAGE_OPTIONS_PACMAN =
	--package ../pkg/
	--exclude Makefile
	--depends "bash>=4.0.0"
	--depends "util-linux>=1.0.0"
endef
PACKAGE_OPTIONS_pacman = $(strip $(PACKAGE_OPTIONS_PACMAN))

define PACKAGE_TASK =

.PHONY: vagrant-build-package-$(strip $(1))
vagrant-build-package-$(strip $(1)): vagrant-hook-install vagrant-hook-remove
	@fpm --output-type $(strip $(1) $$(PACKAGE_OPTIONS_$(strip $(1))) $(PACKAGE_OPTIONS_COMMON))
endef

$(eval $(foreach t, $(PACKAGE_TYPES), $(call PACKAGE_TASK, $(t))))


.PHONY: vagrant-test-package-tar
vagrant-test-package-tar:
	@echo "*** $@ ***"
	@/usr/bin/env chapecron > /dev/null 2>&1 || ( cd ../pkg/archive && sudo make install PREFIX=/usr > /dev/null )
	@cd ../tests && make test-install
	@cd ../pkg/archive && sudo make uninstall PREFIX=/usr > /dev/null
	@cd ../tests && make test-removal

.PHONY: vagrant-test-package-deb
vagrant-test-package-deb:
	@echo "*** $@ ***"
	@/usr/bin/env chapecron > /dev/null 2>&1 || ( sudo dpkg --install ../pkg/chapecron_$(VERSION)-1_all.deb > /dev/null )
	@cd ../tests && make test-install
	@sudo dpkg --purge chapecron > /dev/null
	@cd ../tests && make test-removal

.PHONY: vagrant-test-package-rpm
vagrant-test-package-rpm:
	@echo "*** $@ ***"
	@/usr/bin/env chapecron > /dev/null 2>&1 || ( sudo dnf -yq install ../pkg/chapecron-$(VERSION)-1.noarch.rpm > /dev/null )
	@cd ../tests && make test-install
	@sudo dnf -yq remove chapecron > /dev/null
	@cd ../tests && make test-removal

.PHONY: vagrant-test-package-pacman
vagrant-test-package-pacman:
	@echo "*** $@ ***"
	@/usr/bin/env chapecron > /dev/null 2>&1 || ( sudo pacman --noconfirm -U ../pkg/chapecron-$(VERSION)-1-any.pkg.tar.xz > /dev/null )
	@cd ../tests && make test-install
	@sudo pacman --noconfirm --nosave -R chapecron > /dev/null
	@cd ../tests && make test-removal
