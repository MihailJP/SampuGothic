#!/usr/local/bin/fontforge

from sys import stderr, exit
from math import radians
from argparse import ArgumentParser
from locale import getdefaultlocale
import fontforge
import psMat

parser = ArgumentParser()
parser.add_argument(
	'-g', '--generate-font',
	action='store_true', dest='generate', default=False,
	help="Generate font instead of saving ")
actionGroup = parser.add_mutually_exclusive_group()
actionGroup.add_argument(
	'-p', '--pad',
	action='store_const', const='pad', dest='action',
	help="Pads to width specified by -w")
actionGroup.add_argument(
	'-s', '--scale',
	action='store_const', const='scale', dest='action',
	help="Scales to width specified by -w")
parser.add_argument(
	'-w', '--width',
	type=float,
	help="Set to specified width")
parser.add_argument(
	'-k', '--skew',
	type=float, metavar='ANGLE',
	help="Skews by specified angle")
parser.add_argument(
	'-n', '--font-name',
	type=str, metavar='NAME',
	help="Specify Postscript font name")
parser.add_argument(
	'-f', '--family-name',
	type=str, metavar='NAME',
	help="Specify Postscript family name")
parser.add_argument(
	'-l', '--full-name',
	type=str, metavar='NAME',
	help="Specify font name")
parser.add_argument(
	'-t', '--weight', '--subfamily',
	type=str, metavar='NAME',
	help="Specify subfamily (font weight)")
parser.add_argument(
	'-V', '--font-version',
	type=str, metavar='VERSION',
	help="Set font version")
parser.add_argument(
	'-N', '--sfnt-name',
	action='append', type=str, metavar='LANGID:STRID:NAME',
	help="Specify SFNT name (may be specified more than once)")
parser.add_argument(
	'-F', '--sfnt-family-name',
	action='append', type=str, metavar='LANGID:NAME',
	help="Same as -N LANGID:1:NAME")
parser.add_argument(
	'-L', '--sfnt-full-name',
	action='append', type=str, metavar='LANGID:NAME',
	help="Same as -N LANGID:4:NAME")
parser.add_argument(
	'-T', '--sfnt-weight', '--sfnt-subfamily',
	action='append', type=str, metavar='LANGID:NAME',
	help="Same as -N LANGID:2:NAME")
parser.add_argument(
	'-W', '--os2-weight',
	type=int, metavar='WEIGHT',
	help="Specify OS/2 weight (400 for regular, 700 for bold)")
parser.add_argument(
	'--os2-family-class',
	type=int, metavar='FAMILY',
	help="Specify OS/2 family class")
parser.add_argument(
	'-m', '--merge-with',
	action='append', type=str, metavar='FILENAME',
	help="Merge specified fonts (may be specified more than once)")
parser.add_argument(
	'-r', '--round-to-int',
	action='store_true', default=False,
	help="Round coordinates to integer")
parser.add_argument(
	'srcfile',
	type=str,
	help="Source font file")
parser.add_argument(
	'destfile',
	type=str,
	help="Target font file")
args = parser.parse_args()

def glyphsWorthOutputting(font):
	for glyph in font.glyphs():
		if glyph.isWorthOutputting():
			yield glyph

if (args.action is not None) and (args.width is None):
	parser.error('width not specified')
elif (args.action is None) and (args.width is not None):
	parser.error('action not specified')

font = fontforge.open(args.srcfile)
if args.font_name is not None:
	font.fontname = args.font_name
if args.family_name is not None:
	font.familyname = args.family_name
if args.full_name is not None:
	font.fullname = args.full_name
if args.weight is not None:
	font.weight = args.weight

if args.os2_weight is not None:
	font.os2_weight = args.os2_weight
if args.os2_family_class is not None:
	font.os2_family_class = args.os2_family_class

if args.version is not None:
	font.version = args.version

sfnt = []
def addSfntNames(lst, strid = None):
	if lst is not None:
		for names in lst:
			try: # Python 2
				if strid is None:
					nm = names.split(':', 2)
					sfnt.append([
						int(nm[0], 16 if nm[0][0:2] == '0x' else 10),
						int(nm[1]),
						nm[2].decode(getdefaultlocale()[1]).encode('UTF-8')
						])
				else:
					nm = names.split(':', 1)
					sfnt.append([
						int(nm[0], 16 if nm[0][0:2] == '0x' else 10),
						strid,
						nm[1].decode(getdefaultlocale()[1]).encode('UTF-8')
						])
			except AttributeError: # Python 3
				if strid is None:
					nm = names.split(':', 2)
					sfnt.append([
						int(nm[0], 16 if nm[0][0:2] == '0x' else 10),
						int(nm[1]),
						nm[2]
						])
				else:
					nm = names.split(':', 1)
					sfnt.append([
						int(nm[0], 16 if nm[0][0:2] == '0x' else 10),
						strid,
						nm[1]
						])

addSfntNames(args.sfnt_name)
addSfntNames(args.sfnt_family_name, 1)
addSfntNames(args.sfnt_full_name, 4)
addSfntNames(args.sfnt_weight, 2)
for nomen in sfnt:
	font.appendSFNTName(nomen[0], nomen[1], nomen[2])

for glyph in glyphsWorthOutputting(font):
	if args.action == 'scale':
		glyph.transform(
			psMat.scale(args.width / glyph.width, 1.0),
			('partialRefs', 'round'))
	elif args.action == 'pad':
		glyph.transform(
			psMat.translate((args.width - glyph.width) / 2, 0),
			('partialRefs', 'round'))
		glyph.width = int(args.width)
	if args.skew is not None:
		glyph.transform(
			psMat.skew(radians(args.skew)),
			('partialRefs', 'round'))

if args.merge_with is not None:
	for fileName in args.merge_with:
		font2 = fontforge.open(fileName)
		font.encoding = font2.encoding
		font2.em = font.em
		font.selection.none()
		font2.selection.none()
		for glyph in glyphsWorthOutputting(font2):
			if glyph.glyphname not in font:
				font2.selection.select(('more',), glyph.glyphname)
				font.selection.select(('more',), glyph.glyphname)
		font2.copy()
		font.paste()
		font.copyright += "\n\n" + font2.copyright
		font2.close()

if args.round_to_int:
	font.selection.none()
	for glyph in glyphsWorthOutputting(font):
			font.selection.select(('more',), glyph.glyphname)
	font.round()

if args.generate:
	font.generate(args.destfile)
else:
	font.save(args.destfile)
font.close()
