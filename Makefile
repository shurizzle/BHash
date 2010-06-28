TARGET  = bhash
VERSION = 1.0
DESTDIR ?= /usr/bin
LIBDIR  ?= $(DESTDIR:bin=lib)
INSTDIR = $(LIBDIR)/$(TARGET)
DIST    = $(TARGET)-$(VERSION)

all:
	@echo "This is a bash library, type \`make install' to install it"

install: bhash.lib.sh
	@mkdir $(INSTDIR)
	@echo "Coping library..."
	@cp bhash.lib.sh $(INSTDIR)

dist:
	@echo "Creating tarball..."
	@mkdir $(DIST)
	@cp bhash.lib.sh LICENSE Makefile example README.md $(DIST)
	@tar -cf $(DIST).tar $(DIST)
	@rm -Rf $(DIST)
	@gzip $(DIST).tar

.PHONY: all install
