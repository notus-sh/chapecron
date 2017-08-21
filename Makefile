DESTDIR ?=
PREFIX  ?= /usr/local

CONFDIR ?= $(DESTDIR)/etc/chapecron
BINDIR  ?= $(DESTDIR)$(PREFIX)/bin
LIBDIR  ?= $(DESTDIR)$(PREFIX)/lib/chapecron

all:
	@echo "chapecron is a shell script, so there is nothing to do. Try \"make install\" instead."

install: install-chapecron install-plugins install-config

install-chapecron:
	@install -v -m 0755 -d "$(LIBDIR)"
	@install -v -m 0755 ./chapecron "$(LIBDIR)/chapecron"
	@install -v -m 0755 -d "$(BINDIR)"
	@test -s
	@ln -s "$(LIBDIR)/chapecron" "$(BINDIR)/chapecron"

install-plugins:
	@install -v -m 0755 -d "$(LIBDIR)/plugins.d"
	@install -v -m 0755 ./plugins.d/*.sh "$(LIBDIR)/plugins.d"

install-config:
	@install -v -m 0755 -d "$(CONFDIR)"
	@install -v -m 0755 ./chapecron.conf "$(CONFDIR)/chapecron.conf"

uninstall:
	@rm -vrf "$(LIBDIR)" "$(CONFDIR)" "$(BINDIR)/chapecron"

test:
	@cd tests && make

.PHONY: install uninstall install-chapecron install-plugins install-config test
