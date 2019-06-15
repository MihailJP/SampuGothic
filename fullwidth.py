#!/usr/local/bin/fontforge

import sys
import fontforge
import psMat
import math

font = fontforge.open(sys.argv[1])
font.encoding='UnicodeBmp'
font.selection.select(('ranges',), 0x21, 0x7e)
font.copy()
font.selection.select(0xff01)
font.paste()
font.selection.select(('ranges',), 0xff01, 0xff5e)
if font.italicangle:
	font.transform(psMat.skew(font.italicangle * math.pi / 180.0))
font.transform(psMat.scale(1.5, 1.0))
font.transform(psMat.translate(153.25, 0))
font[0xff03].transform(psMat.skew(-10 * math.pi / 180.0))
font[0xff10].transform(psMat.skew(30 * math.pi / 180.0))
font[0xff15].transform(psMat.skew(-5 * math.pi / 180.0))
for glyph in font.selection.byGlyphs:
	glyph.glyphname = font[glyph.encoding - 0xff00 + 0x20].glyphname + 'monospace'
	glyph.width = 1226
	newLayer = fontforge.layer()
	for contour in glyph.layers[1]:
		newContour = fontforge.contour()
		for i in range(0, len(contour)):
			delta1 = (contour[(i + 1) % len(contour)].x - contour[i].x, contour[(i + 1) % len(contour)].y - contour[i].y)
			delta2 = (contour[i].x - contour[i - 1].x, contour[i].y - contour[i - 1].y)
			angle1 = math.atan2(delta1[1], delta1[0])
			angle2 = math.atan2(delta2[1], delta2[0])
			angle = angle1 if abs(math.sin(angle1)) >= abs(math.sin(angle2)) else angle2
			if (delta1[1] * delta2[1] >= 0) or (abs(delta1[0]) < 15) or (abs(delta2[0]) < 15):
				newContour += fontforge.point(contour[i].x + 20 * math.sin(angle), contour[i].y, contour[i].on_curve)
			else:
				newContour += contour[i]
		newContour.closed = True
		newLayer += newContour
	glyph.layers[1] = newLayer
font[0xff03].transform(psMat.skew(10 * math.pi / 180.0))
font[0xff10].transform(psMat.skew(-30 * math.pi / 180.0))
font[0xff15].transform(psMat.skew(5 * math.pi / 180.0))
if font.italicangle:
	font.transform(psMat.skew(-font.italicangle * math.pi / 180.0))
font.autoHint()
font.save(sys.argv[2])
