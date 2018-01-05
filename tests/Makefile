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

.PHONY: all
all: aggregate

.PHONY: aggregate
aggregate: clean-test-results $(TEST_SUITE)
	@echo "*** $@ ***"
	@ls test-results/t*-*.sh.*.counts | ../vendor/sharness/aggregate-results.sh

.PHONY: $(TEST_SUITE)
$(TEST_SUITE): clean-test-results deps
	@echo "*** $@ ***"
	@[ $(VERBOSE) ] && ./$@ --verbose || ./$@

.PHONY: clean-test-results
clean-test-results:
	@-rm -rf test-results


INSTALL_TEST_SUITE = $(sort $(wildcard p0-*/p[0-9][0-9][0-9][0-9]-*.sh))
REMOVAL_TEST_SUITE = $(sort $(wildcard p1-*/p[0-9][0-9][0-9][0-9]-*.sh))

.PHONY: test-install
test-install: clean-test-results $(INSTALL_TEST_SUITE)
	@echo "*** $@ ***"
	@ls test-results/p0[0-9][0-9][0-9]-*.sh.*.counts | ../vendor/sharness/aggregate-results.sh

.PHONY: $(INSTALL_TEST_SUITE)
$(INSTALL_TEST_SUITE): clean-test-results deps
	@echo "*** $@ ***"
	@[ $(VERBOSE) ] && ./$@ --verbose || ./$@

.PHONY: test-removal
test-removal: clean-test-results $(REMOVAL_TEST_SUITE)
	@echo "*** $@ ***"
	@ls test-results/p1[0-9][0-9][0-9]-*.sh.*.counts | ../vendor/sharness/aggregate-results.sh

.PHONY: $(REMOVAL_TEST_SUITE)
$(REMOVAL_TEST_SUITE): clean-test-results deps
	@echo "*** $@ ***"
	@[ $(VERBOSE) ] && ./$@ --verbose || ./$@


.PHONY: deps
deps: sharness shellmock

.PHONY: sharness
sharness:
	@./install-dep.sh sharness $(SHARNESS_REPOSITORY) $(SHARNESS_REVISION)

.PHONY: shellmock
shellmock:
	@./install-dep.sh shellmock $(SHELLMOCK_REPOSITORY) $(SHELLMOCK_REVISION)
