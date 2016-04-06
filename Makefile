TARGETS=SampuGothic.ttf SampuGothic-Italic.ttf
DOWNLOADABLES=dump.tar.gz
GENERATABLES=dump_newest_only.txt dump_all_versions.txt parts.txt makeglyph.js \
work.sfd work.scr work.log glyphs.txt \
work-scaled.sfd work-scaled-obl.sfd

FONT_NAME_E=Sampu Gothic
FONT_NAME_J=算譜ゴシック
FONT_OPTIONS=-n SampuGothic -f "$(FONT_NAME_E)" -F "0x0411:$(FONT_NAME_J)"

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
	./replace-glyph.rb -i -l nisui-sanzui.csv -l variants.csv -l jisx-0208-hikanji.csv -l wakammuri.csv > $@

makeglyph.js: kage/makettf/makeglyph.js makeglyph-patch.sed
	cat kage/makettf/makeglyph.js | sed -f makeglyph-patch.sed > $@

glyphs.txt: jisx-0208-hikanji.lst jisx-level1.lst
	cat $^ | sed -e 's/\s*#.*$$//' -e '/^$$/d'> $@

work.sfd: head.txt parts.txt foot.txt makeglyph.js glyphs.txt
	./makesvg.py gothic 5
	cd build; $(MAKE) -j`nproc`
	export LANG=utf-8; fontforge -script work.scr >> work.log 2>&1

work-scaled.sfd: work.sfd
	./adjustFont.py -sw1226 $< $@
work-scaled-obl.sfd: work.sfd
	./adjustFont.py -sw1226 -k10 $< $@

SampuGothic.ttf: Inconsolata-LGC/Inconsolata-LGC.sfd work-scaled.sfd
	./adjustFont.py -g $(FONT_OPTIONS) \
	-l "$(FONT_NAME_E)" -L "0x0411:$(FONT_NAME_J)" \
	-t "Regular" -T "0x0411:標準" \
	-m work-scaled.sfd $< $@
SampuGothic-Italic.ttf: Inconsolata-LGC/Inconsolata-LGC-Italic.sfd work-scaled-obl.sfd
	./adjustFont.py -g $(FONT_OPTIONS) \
	-l "$(FONT_NAME_E) Italic" -L "0x0411:$(FONT_NAME_J) 斜体" \
	-t "Italic" -T "0x0411:斜体" \
	-m work-scaled-obl.sfd $< $@

clean:
	rm -f $(TARGETS) $(GENERATABLES)
	rm -rf build

distclean: clean
	rm -f $(DOWNLOADABLES)
