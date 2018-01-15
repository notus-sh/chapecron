
.PHONY: test
test:
	@cd tests && make

.PHONY: build
build:
	@cd build && make build


.DEFAULT_GOAL := build-archive
.PHONY: build-archive
build-archive:
	@cd build && make build-archive

.PHONY: install
install:
	@cd pkg/archive && make install
