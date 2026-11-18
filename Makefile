PREFIX ?= /usr/local

install:
	install -Dm755 ncmpcppv $(DESTDIR)$(PREFIX)/bin/ncmpcppv

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/ncmpcppv

.PHONY: install uninstall
