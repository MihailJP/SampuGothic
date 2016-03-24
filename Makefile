TARGETS=fetch
DOWNLOADABLES=dump.tar.gz
GENERATABLES=dump_newest_only.txt dump_all_versions.txt

.PHONY: all fetch clean distclean
all: $(TARGETS)

.DELETE_ON_ERROR: $(GENERATABLES) $(DOWNLOADABLES)

fetch: $(DOWNLOADABLES)

dump.tar.gz:
	wget -O $@ http://glyphwiki.org/dump.tar.gz

dump_newest_only.txt: dump.tar.gz
	tar xfz $< $@ && touch $@
dump_all_versions.txt: dump.tar.gz
	tar xfz $< $@ && touch $@

clean:
	rm -f $(TARGETS) $(GENERATABLES)

distclean: clean
	rm -f $(DOWNLOADABLES)
