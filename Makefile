.PHONY: test
test:
	@cd tests && make

.PHONY: build
build:
	@cd build && make build

.PHONY: install
install:
	@cd build && make build-archive
	@cd pkg/archive && make install
