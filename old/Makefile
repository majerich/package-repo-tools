PREFIX ?= /usr
SYSCONFDIR ?= /etc
LIBDIR ?= $(PREFIX)/lib
BINDIR ?= $(PREFIX)/bin
DOCDIR ?= $(PREFIX)/share/doc/$(PACKAGE)

PACKAGE = package-repo-tools
VERSION = 2.0.0

.PHONY: all install uninstall clean

all: build

build:
	@echo "Building $(PACKAGE) $(VERSION)..."

install:
	@echo "Installing $(PACKAGE)..."
	install -Dm755 src/package-repo-restore.sh $(DESTDIR)$(BINDIR)/package-repo-restore
	install -Dm755 src/package-repo-report.sh $(DESTDIR)$(BINDIR)/package-repo-report
	
	# Install library files
	for lib in src/lib/*.sh; do \
		install -Dm644 $$lib $(DESTDIR)$(LIBDIR)/$(PACKAGE)/$$(basename $$lib); \
	done
	
	# Install configuration
	install -Dm644 config/package-repo-tools.conf $(DESTDIR)$(SYSCONFDIR)/package-repo-tools.conf
	
	# Install documentation
	install -Dm644 README.md $(DESTDIR)$(DOCDIR)/README.md
	install -Dm644 LICENSE $(DESTDIR)$(DOCDIR)/LICENSE

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/package-repo-restore
	rm -f $(DESTDIR)$(BINDIR)/package-repo-report
	rm -rf $(DESTDIR)$(LIBDIR)/$(PACKAGE)
	rm -f $(DESTDIR)$(SYSCONFDIR)/package-repo-tools.conf
	rm -rf $(DESTDIR)$(DOCDIR)

clean:
	rm -f *.tar.gz
	rm -rf pkg src
