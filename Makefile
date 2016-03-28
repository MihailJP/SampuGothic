TARGETS=work.sfd
DOWNLOADABLES=dump.tar.gz
GENERATABLES=dump_newest_only.txt dump_all_versions.txt parts.txt makeglyph.js \
work.sfd work.scr work.log glyphs.txt

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

parts.txt: dump_newest_only.txt dump_all_versions.txt
	cat dump_newest_only.txt dump_all_versions.txt | ./mkparts.pl | ./kage-roofed-l2rd.rb | \
	./replace-glyph.rb -l nisui-sanzui.csv -l variants.csv -l jisx-0208-hikanji.csv > $@

makeglyph.js: kage/makettf/makeglyph.js makeglyph-patch.sed
	cat kage/makettf/makeglyph.js | sed -f makeglyph-patch.sed > $@

glyphs.txt: jisx-0208-hikanji.lst jisx-level1.lst
	cat $^ | sed -e 's/\s*#.*$$//' -e '/^$$/d'> $@

work.sfd: head.txt parts.txt foot.txt makeglyph.js glyphs.txt
	./makesvg.py . work gothic 3
	cd build; $(MAKE) -j`nproc`
	export LANG=utf-8; fontforge -script work.scr >> work.log 2>&1

clean:
	rm -f $(TARGETS) $(GENERATABLES)
	rm -rf build

distclean: clean
	rm -f $(DOWNLOADABLES)
