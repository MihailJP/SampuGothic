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
Inconsolata-LGC-Bold.sfd Inconsolata-LGC-BoldItalic.sfd

FONT_NAME_E=Sampu Gothic
FONT_NAME_J=算譜ゴシック
FONT_VERSION=0.1
FONT_OPTIONS=-n SampuGothic -f "$(FONT_NAME_E)" -F "0x0411:$(FONT_NAME_J)" -V "$(FONT_VERSION)" -r

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

glyphs.txt: jisx-0208-hikanji.lst jisx-level1.lst jisx-level2.lst
	cat $^ | sed -e 's/\s*#.*$$//' -e '/^$$/d'> $@

work.sfd: head.txt parts.txt foot.txt makeglyph.js glyphs.txt
	./makesvg.py gothic 4
	cd build; $(MAKE) -j`nproc`
	export LANG=utf-8; fontforge -script work.scr >> work.log 2>&1

work-scaled.sfd: work.sfd
	./adjustFont.py -sw1226 $< $@
work-scaled-obl.sfd: work.sfd
	./adjustFont.py -sw1226 -k10 $< $@

Inconsolata-LGC.sfd: Inconsolata-LGC/Inconsolata-LGC.sfd
	cat $^ | sed -e '/^Panose/d' > $@
Inconsolata-LGC-Italic.sfd: Inconsolata-LGC/Inconsolata-LGC-Italic.sfd
	cat $^ | sed -e '/^Panose/d' > $@

SampuGothic.raw.ttf: Inconsolata-LGC.sfd work-scaled.sfd
	./adjustFont.py -g $(FONT_OPTIONS) \
	-l "$(FONT_NAME_E)" -L "0x0411:$(FONT_NAME_J)" \
	-t "Regular" -T "0x0411:標準" --os2-weight=400 \
	-m work-scaled.sfd $< $@
SampuGothic-Italic.raw.ttf: Inconsolata-LGC-Italic.sfd work-scaled-obl.sfd
	./adjustFont.py -g $(FONT_OPTIONS) \
	-l "$(FONT_NAME_E) Italic" -L "0x0411:$(FONT_NAME_J) 斜体" \
	-t "Italic" -T "0x0411:斜体" --os2-weight=400 \
	-m work-scaled-obl.sfd $< $@

work-b.sfd: head.txt parts.txt foot.txt makeglyph.js glyphs.txt
	./makesvg.py -s build-b -t work-b gothic 7
	cd build-b; $(MAKE) -j`nproc`
	export LANG=utf-8; fontforge -script work-b.scr >> work-b.log 2>&1

work-b-scaled.sfd: work-b.sfd
	./adjustFont.py -sw1226 $< $@
work-b-scaled-obl.sfd: work-b.sfd
	./adjustFont.py -sw1226 -k10 $< $@

Inconsolata-LGC-Bold.sfd: Inconsolata-LGC/Inconsolata-LGC-Bold.sfd
	cat $^ | sed -e '/^Panose/d' > $@
Inconsolata-LGC-BoldItalic.sfd: Inconsolata-LGC/Inconsolata-LGC-BoldItalic.sfd
	cat $^ | sed -e '/^Panose/d' > $@

SampuGothic-Bold.raw.ttf: Inconsolata-LGC-Bold.sfd work-b-scaled.sfd
	./adjustFont.py -g $(FONT_OPTIONS) \
	-l "$(FONT_NAME_E) Bold" -L "0x0411:$(FONT_NAME_J) 太字" \
	-t "Bold" -T "0x0411:太字" --os2-weight=700 \
	-m work-b-scaled.sfd $< $@
SampuGothic-BoldItalic.raw.ttf: Inconsolata-LGC-BoldItalic.sfd work-b-scaled-obl.sfd
	./adjustFont.py -g $(FONT_OPTIONS) \
	-l "$(FONT_NAME_E) Bold Italic" -L "0x0411:$(FONT_NAME_J) 太字斜体" \
	-t "Bold Italic" -T "0x0411:太字斜体" --os2-weight=700 \
	-m work-b-scaled-obl.sfd $< $@

TTX_COMMAND=ttx -o $@ $<
SampuGothic.raw.ttx: SampuGothic.raw.ttf
	$(TTX_COMMAND)
SampuGothic-Italic.raw.ttx: SampuGothic-Italic.raw.ttf
	$(TTX_COMMAND)
SampuGothic-Bold.raw.ttx: SampuGothic-Bold.raw.ttf
	$(TTX_COMMAND)
SampuGothic-BoldItalic.raw.ttx: SampuGothic-BoldItalic.raw.ttf
	$(TTX_COMMAND)

SET_FIXED_PITCH_FLAG=cat $< | sed -e '/isFixedPitch/c <isFixedPitch value="1"/>' -e '/bProportion/c <bProportion value="9"/>' > $@
SampuGothic.ttx: SampuGothic.raw.ttx
	$(SET_FIXED_PITCH_FLAG)
SampuGothic-Italic.ttx: SampuGothic-Italic.raw.ttx
	$(SET_FIXED_PITCH_FLAG)
SampuGothic-Bold.ttx: SampuGothic-Bold.raw.ttx
	$(SET_FIXED_PITCH_FLAG)
SampuGothic-BoldItalic.ttx: SampuGothic-BoldItalic.raw.ttx
	$(SET_FIXED_PITCH_FLAG)

SampuGothic.ttf: SampuGothic.ttx
	$(TTX_COMMAND)
SampuGothic-Italic.ttf: SampuGothic-Italic.ttx
	$(TTX_COMMAND)
SampuGothic-Bold.ttf: SampuGothic-Bold.ttx
	$(TTX_COMMAND)
SampuGothic-BoldItalic.ttf: SampuGothic-BoldItalic.ttx
	$(TTX_COMMAND)

clean:
	rm -f $(TARGETS) $(GENERATABLES)
	rm -rf build
	rm -rf build-b

distclean: clean
	rm -f $(DOWNLOADABLES)
