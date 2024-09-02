TARGETS=SampuGothic.ttf SampuGothic-Italic.ttf SampuGothic-Bold.ttf SampuGothic-BoldItalic.ttf
DOWNLOADABLES=dump.tar.gz
GENERATABLES=dump_newest_only.txt dump_all_versions.txt parts.txt makeglyph.js \
work.sfd work.scr work.log glyphs.txt \
work-scaled.sfd work-scaled-obl.sfd \
work-b.sfd work-b.scr work-b.log \
work-b-scaled.sfd work-b-scaled-obl.sfd \
Inconsolata-LGC.sfd Inconsolata-LGC-Italic.sfd \
Inconsolata-LGC-Bold.sfd Inconsolata-LGC-BoldItalic.sfd \
Inconsolata-LGC.raw.ttf Inconsolata-LGC-Italic.raw.ttf \
Inconsolata-LGC-Bold.raw.ttf Inconsolata-LGC-BoldItalic.raw.ttf \
Inconsolata-LGC.raw.ttx Inconsolata-LGC-Italic.raw.ttx \
Inconsolata-LGC-Bold.raw.ttx Inconsolata-LGC-BoldItalic.raw.ttx \
Inconsolata-LGC.sfd Inconsolata-LGC-Italic.sfd \
Inconsolata-LGC-Bold.sfd Inconsolata-LGC-BoldItalic.sfd \
$(TARGETS:.ttf=.ttx) $(TARGETS:.ttf=.raw.ttx) $(TARGETS:.ttf=.raw.ttf) \
ChangeLog
ARCHIVE_CONTENTS=$(TARGETS) LICENSE LICENSE.kage.engine \
LICENSE.kage.glyphs README.md ChangeLog
ARCHIVES=SampuGothic.tar.xz

FONT_NAME=SampuGothic
FONT_NAME_E=Sampu Gothic
FONT_NAME_J=算譜ゴシック
FONT_VERSION=0.9
FONT_OPTIONS=-n SampuGothic -n "$(FONT_NAME)" -f "$(FONT_NAME_E)" -F "0x0411:$(FONT_NAME_J)" -V "$(FONT_VERSION)" -r

.PHONY: all fetch clean distclean mostlyclean
all: $(TARGETS)

.DELETE_ON_ERROR: $(GENERATABLES) $(DOWNLOADABLES)

fetch: $(DOWNLOADABLES)

dump.tar.gz:
	wget -O $@ http://glyphwiki.org/dump.tar.gz

dump_newest_only.txt: dump.tar.gz
	tar xfz $< $@ && touch $@
dump_all_versions.txt: dump.tar.gz
	tar xfz $< $@ && touch $@

parts.txt: dump_newest_only.txt dump_all_versions.txt \
mkparts.pl kage-roofed-l2rd.rb replace-glyph.rb \
nisui-sanzui.csv variants.csv jisx-0208-hikanji.csv wakammuri.csv sans.csv
	cat dump_newest_only.txt dump_all_versions.txt | ./mkparts.pl | ./kage-roofed-l2rd.rb | \
	./replace-glyph.rb -i -l nisui-sanzui.csv -l variants.csv -l jisx-0208-hikanji.csv -l wakammuri.csv -l sans.csv > $@

makeglyph.js: makeglyph/makeglyph.js
	ln -s $< $@

glyphs.txt: jisx-0208-hikanji.lst jisx-level1.lst jisx-level2.lst cp932-additional.lst jisx-level3.lst jisx-level4.lst
	cat $^ | sed -e 's/\s*#.*$$//' -e '/^$$/d'> $@

.INTERMEDIATE: work.scr
work.scr: head.txt parts.txt foot.txt makeglyph.js glyphs.txt
	./makesvg.py gothic 4
work.sfd: work.scr
	cd build; $(MAKE) -j`nproc`
	export LANG=utf-8; fontforge -script work.scr >> work.log 2>&1

.INTERMEDIATE: work-scaled.sfd work-scaled-obl.sfd
work-scaled.sfd: work.sfd
	fontforge ./adjustFont.py -M1024 -sw1226 $< $@
work-scaled-obl.sfd: work.sfd
	fontforge ./adjustFont.py -M1024 -sw1226 -k10 $< $@

.INTERMEDIATE: Inconsolata-LGC.tmp.sfd Inconsolata-LGC-Italic.tmp.sfd
Inconsolata-LGC.tmp.sfd: Inconsolata-LGC/Inconsolata-LGC.sfd
	fontforge ./fullwidth.py $< $@
Inconsolata-LGC-Italic.tmp.sfd: Inconsolata-LGC/Inconsolata-LGC-Italic.sfd
	fontforge ./fullwidth.py $< $@
Inconsolata-LGC.sfd: Inconsolata-LGC.tmp.sfd
	cat $^ | sed -e '/^Panose/d' > $@
Inconsolata-LGC-Italic.sfd: Inconsolata-LGC-Italic.tmp.sfd
	cat $^ | sed -e '/^Panose/d' > $@

SampuGothic.raw.ttf: Inconsolata-LGC.sfd work-scaled.sfd
	fontforge ./adjustFont.py -g $(FONT_OPTIONS) \
	-n "$(FONT_NAME)" -l "$(FONT_NAME_E)" -L "0x0411:$(FONT_NAME_J)" \
	-t "Regular" -T "0x0411:標準" --os2-weight=400 \
	-m work-scaled.sfd $< $@
SampuGothic-Italic.raw.ttf: Inconsolata-LGC-Italic.sfd work-scaled-obl.sfd
	fontforge ./adjustFont.py -g $(FONT_OPTIONS) \
	-n "$(FONT_NAME)-Italic" -l "$(FONT_NAME_E) Italic" -L "0x0411:$(FONT_NAME_J) 斜体" \
	-t "Italic" -T "0x0411:斜体" --os2-weight=400 \
	-m work-scaled-obl.sfd $< $@

.INTERMEDIATE: work-b.scr
work-b.scr: head.txt parts.txt foot.txt makeglyph.js glyphs.txt
	./makesvg.py -s build-b -t work-b gothic 7
work-b.sfd: work-b.scr
	cd build-b; $(MAKE) -j`nproc`
	export LANG=utf-8; fontforge -script work-b.scr >> work-b.log 2>&1

.INTERMEDIATE: work-b-scaled.sfd work-b-scaled-obl.sfd
work-b-scaled.sfd: work-b.sfd
	fontforge ./adjustFont.py -M1024 -sw1226 $< $@
work-b-scaled-obl.sfd: work-b.sfd
	fontforge ./adjustFont.py -M1024 -sw1226 -k10 $< $@

.INTERMEDIATE: Inconsolata-LGC-Bold.tmp.sfd Inconsolata-LGC-BoldItalic.tmp.sfd
Inconsolata-LGC-Bold.tmp.sfd: Inconsolata-LGC/Inconsolata-LGC-Bold.sfd
	fontforge ./fullwidth.py $< $@
Inconsolata-LGC-BoldItalic.tmp.sfd: Inconsolata-LGC/Inconsolata-LGC-BoldItalic.sfd
	fontforge ./fullwidth.py $< $@
Inconsolata-LGC-Bold.sfd: Inconsolata-LGC-Bold.tmp.sfd
	cat $^ | sed -e '/^Panose/d' > $@
Inconsolata-LGC-BoldItalic.sfd: Inconsolata-LGC-BoldItalic.tmp.sfd
	cat $^ | sed -e '/^Panose/d' > $@

SampuGothic-Bold.raw.ttf: Inconsolata-LGC-Bold.sfd work-b-scaled.sfd
	fontforge ./adjustFont.py -g $(FONT_OPTIONS) \
	-n "$(FONT_NAME)-Bold" -l "$(FONT_NAME_E) Bold" -L "0x0411:$(FONT_NAME_J) 太字" \
	-t "Bold" -T "0x0411:太字" --os2-weight=700 \
	-m work-b-scaled.sfd $< $@
SampuGothic-BoldItalic.raw.ttf: Inconsolata-LGC-BoldItalic.sfd work-b-scaled-obl.sfd
	fontforge ./adjustFont.py -g $(FONT_OPTIONS) \
	-n "$(FONT_NAME)-BoldItalic" -l "$(FONT_NAME_E) Bold Italic" -L "0x0411:$(FONT_NAME_J) 太字斜体" \
	-t "Bold Italic" -T "0x0411:太字斜体" --os2-weight=700 \
	-m work-b-scaled-obl.sfd $< $@

.INTERMEDIATE: $(TARGETS:.ttf=.ttx) $(TARGETS:.ttf=.raw.ttx) $(TARGETS:.ttf=.raw.ttf)
%.raw.ttx: %.raw.ttf
	ttx -t post -t "OS/2" -o $@ $<
%.ttx: %.raw.ttx
	cat $< | sed -e '/isFixedPitch/s/value=".*"/value="1"/' -e '' -e '/bProportion/s/value=".*"/value="9"/' > $@
%.ttf: %.raw.ttf %.ttx
	ttx -o $@ -m $^

ChangeLog:
	./mkchglog.rb > $@

SampuGothic.tar.xz: $(ARCHIVE_CONTENTS)
	mkdir -p SampuGothic && cp $^ SampuGothic && tar cfvJ $@ SampuGothic && rm -rf SampuGothic

.PHONY: dist
dist: $(ARCHIVES)

mostlyclean:
	rm -f $(TARGETS) $(GENERATABLES) $(ARCHIVES)
	rm -rf SampuGothic

clean: mostlyclean
	rm -rf build
	rm -rf build-b

distclean: clean
	rm -f $(DOWNLOADABLES)
