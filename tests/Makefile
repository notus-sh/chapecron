# Run sharness tests
#
# NOTE: Run with VERBOSE=1 for verbose tests.

: ${VERBOSE:=0}

# Test dependencies
SHARNESS_REPOSITORY   = https://github.com/chriscool/sharness.git
SHARNESS_REVISION     = e94c6bbb04e8772eb9dd587aee3b721c9b01d282

SHELLMOCK_REPOSITORY  = https://github.com/capitalone/bash_shell_mock.git
SHELLMOCK_REVISION    = 8fd1b4b21e5f3f323b1664f658dc7e085095adb8


TEST_SUITE = $(sort $(wildcard t[0-9]-*/t[0-9][0-9][0-9][0-9]-*.sh))


all: aggregate

aggregate: clean-test-results $(TEST_SUITE)
	@echo "*** $@ ***"
	ls test-results/t*-*.sh.*.counts | ../vendor/sharness/aggregate-results.sh

$(TEST_SUITE): clean-test-results deps
	@echo "*** $@ ***"
	@[ $(VERBOSE) ] && ./$@ --verbose || ./$@

clean-test-results:
	@echo "*** $@ ***"
	-rm -rf test-results

deps: sharness shellmock

sharness:
	@echo "*** checking $@ ***"
	./install-dep.sh sharness $(SHARNESS_REPOSITORY) $(SHARNESS_REVISION)

shellmock:
	@echo "*** checking $@ ***"
	./install-dep.sh shellmock $(SHELLMOCK_REPOSITORY) $(SHELLMOCK_REVISION)

.PHONY: all clean-test-results $(TEST_SUITE) aggregate deps sharness shellmock
