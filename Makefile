VERSION = $(shell sed -e "s/[[:space:]]//g" < ./VERSION)

.PHONY: test
test:
	@cd tests && make

.PHONY: build
build: build-archive

.PHONY: build-archive
build-archive:
	@rm -rf pkg/archive && mkdir -p pkg/archive
	@cp -t pkg/archive/ COPYING LICENSE
	@cp Makefile.dist pkg/archive/Makefile
	@mkdir -p pkg/archive/plugins.d
	@cp plugins.d/*.sh pkg/archive/plugins.d/
	@sed -e "s/^.*__PKG__ //; s/__VERSION__/$(VERSION)/" chapecron > pkg/archive/chapecron
