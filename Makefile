VERSION = $(shell sed -e "s/[[:space:]]//g" < ./VERSION)

test:
	@cd tests && make

build: build-archive

build-archive:
	@rm -rf pkg/archive && mkdir -p pkg/archive
	@cp -t pkg/archive/ COPYING LICENSE
	@cp Makefile.dist pkg/archive/Makefile
	@mkdir -p pkg/archive/plugins.d
	@cp plugins.d/*.sh pkg/archive/plugins.d/
	@echo $(VERSION)
	@sed -e "s/^.*__PKG__ //; s/__VERSION__/$(VERSION)/" chapecron > pkg/archive/chapecron

.PHONY: test build-archive
