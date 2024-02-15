#!/usr/bin/env python
# -*- coding: utf-8 -*-

FONTFORGE = "export LANG=utf-8; env fontforge"
MAKEGLYPH = "/usr/bin/js ./makeglyph.js"
MV = "/bin/mv"

from sys import exit
from os import system
from os.path import exists
import re
from argparse import ArgumentParser
try:
	from urllib.parse import quote_plus
except ImportError:
	from urllib import quote_plus


parser = ArgumentParser()
parser.add_argument(
	'-H', '--header',
	type=str, default='head.txt', metavar='FILENAME',
	help="Specify script header file (default: head.txt)")
parser.add_argument(
	'-p', '--parts',
	type=str, default='parts.txt', metavar='FILENAME',
	help="Specify script header file (default: parts.txt)")
parser.add_argument(
	'-F', '--footer',
	type=str, default='foot.txt', metavar='FILENAME',
	help="Specify script footer file (default: foot.txt)")
parser.add_argument(
	'-s', '--svg-dir',
	type=str, default='build', metavar='DIRNAME',
	help="Specify temporary SVG directory (default: build)")
parser.add_argument(
	'-w', '--work-dir',
	type=str, default='.', metavar='DIRNAME',
	help="Specify working directory (default: .)")
parser.add_argument(
	'-t', '--target',
	type=str, default='work', metavar='BASENAME',
	help="Specify target file name (default: work)")
parser.add_argument(
	'shotai',
	type=str,
	help="Specify font face (mincho or gothic)")
parser.add_argument(
	'weight',
	type=int,
	help="Specify font weight (1, 3, 5, 7)")
args = parser.parse_args()

def unlink(filename):
	import os, errno
	try:
		os.unlink(filename)
	except OSError:
		pass

def mkdir(dirname):
	import os, errno
	try:
		os.mkdir(dirname)
	except OSError:
		pass

unlink(args.work_dir+"/"+args.target+".log")
unlink(args.work_dir+"/"+args.target+".scr")
unlink(args.work_dir+"/"+args.target+".ttf")
mkdir(args.work_dir+"/"+args.svg_dir)

LOG = open(args.work_dir+"/"+args.target+".log", "a")

buhin = {}
targetDict = {}

##############################################################################

def render(target, partsdata, code):
	LOG.write(code+" : "+(" ".join([MAKEGLYPH, target, partsdata, args.shotai, str(args.weight)]))+"\n")
	svgBaseName = args.work_dir+"/"+args.svg_dir+"/"+code
	svgcmd = "cd ..; " + (" ".join([MAKEGLYPH, target, partsdata, args.shotai, str(args.weight)])) + " > " + args.svg_dir + "/" + code + ".raw.svg; cd " + args.svg_dir
	needsUpdate = False
	if not exists(svgBaseName+".sh"):
		needsUpdate = True
	else:
		with open(svgBaseName+".sh", "r") as FH:
			if FH.readline().rstrip('\n') != svgcmd:
				needsUpdate = True
	if needsUpdate:
		with open(svgBaseName+".sh", "w") as FH:
			FH.write(svgcmd + "\n")
			FH.write("convert {0}.raw.svg -density 400 -resize 400x400 -background white -flatten -alpha off {0}.bmp\n".format(code))
			FH.write("if [ $? -ne 0 ]; then exit 2; fi\n")
			FH.write("potrace -s {0}.bmp -o {0}.svg\n".format(code))
			FH.write("if [ $? -ne 0 ]; then exit 2; fi\n")
			FH.write("rm -f " + code+".raw.svg\n")
			FH.write("rm -f " + code+".bmp\n")

##############################################################################

def addglyph(code, refGlyph, target):
	textbuf = """Print(0u{0})
Select(0u{0})
Clear()
Import("{3}/{4}/{0}.svg")
Scale(500, 0, 0)
CanonicalContours()
CanonicalStart()
RoundToInt()
FindIntersections()
RoundToInt()
SetGlyphComment("Kage: {1}\\nAlias: {2}")
Simplify()
Scale(20, 0, 0)
SetWidth(1000)
RoundToInt()
AutoHint()
""".format(code, refGlyph, target, args.work_dir, args.svg_dir)
	while True:
		try:
			FH = open(args.work_dir+"/"+args.target+".scr", "a")
		except IOError:
			continue
		FH.write(textbuf)
		FH.close()
		break

##############################################################################

def makefont():
	textbuf = "Save(\""+args.work_dir+"/"+args.target+".sfd\")\n"
	textbuf += "Quit()\n"
	with open(args.work_dir+"/"+args.target+".scr", "a") as FH:
		FH.write(textbuf)

##############################################################################

def addsubset(subset, target):
	subset[target] = buhin[target]
	txtbuf = '$'+buhin[target]+'$'
	for match in re.findall(r"(\$99:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:([^\$:]*)(?::[^\$]*)?)", txtbuf):
		if match[1].strip() not in subset:
			addsubset(subset, match[1].strip())

##############################################################################

# initialize
if exists(args.work_dir+"/"+args.header):
	with open(args.work_dir+"/"+args.header, "r") as FH:
		with open(args.work_dir+"/"+args.target+".scr", "a") as FH2:
			for line in FH:
				FH2.write(line)

	LOG.write("Prepare header file ... done.\n")
else:
	LOG.write("No header file.\n")
	LOG.close()
	exit(2)

# parse buhin
temp = []
if exists(args.work_dir+"/"+args.parts):
	with open(args.work_dir+"/"+args.parts, "r") as FH:
		temp = FH.readlines()
	LOG.write("Prepare parts file ... done.\n")
else:
	LOG.write("No parts file.\n")
	LOG.close()
	exit(2)

for tmpdat in temp:
	if re.search(":", tmpdat):
		temp2 = re.split(r" +|\t", tmpdat)
		buhin[temp2[0]] = temp2[1]
LOG.write("Prepare parts data ... done.\n")

# parse target code point
with open("./glyphs.txt", "r") as GLYPHLIST: # or die "Cannot read the glyph list"
	for line in GLYPHLIST:
		name = re.sub(r"\r?\n$", "", line)
		target = re.sub(r"^[uU]0*", "", name) # delete zero for the beginning
		targetDict[target] = name
LOG.write("Prepare target code point ... done.\n")

# make glyph for each target
LOG.write("Prepare each glyph.\n")

targets = sorted(list(set(targetDict.keys())))
with open(args.work_dir+"/"+args.svg_dir+"/Makefile", "w") as FH:
	FH.write("TARGETS=\\\n")
	for code in targets:
		FH.write(code + ".svg \\\n")
	FH.write("""
.PHONY: all clean

all: $(TARGETS)

.SUFFIXES: .svg .sh
.sh.svg:
	sh $^

clean:
	rm -f *.svg *.bmp *.png
""")
for code in targets:
	#LOG.write(code+" : ")
	refGlyph = targetDict[code]
	subset = {}
	addsubset(subset, refGlyph.strip())
	partsdata = ""
	for subsetKey in subset.keys():
		partsdata += subsetKey+" "+subset[subsetKey]+"\n"
	target = quote_plus(refGlyph.encode('utf-8'))
	partsdata = quote_plus(partsdata.encode('utf-8'))
	render(target, partsdata, code)
	addglyph(code, refGlyph, target)
LOG.write("Prepare each glyph ... done.\n")

# scripts footer
if exists(args.work_dir+"/"+args.footer):
	with open(args.work_dir+"/"+args.footer, "r") as FH:
		with open(args.work_dir+"/"+args.target+".scr", "a") as FH2:
			for txtbuf in FH:
				FH2.write(txtbuf)
	
	LOG.write("Prepare footer file ... done.\n")
else:
	LOG.write("No footer file.\n")
	LOG.close()
	exit(2)

LOG.close()
makefont()
