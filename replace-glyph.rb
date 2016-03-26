#!/usr/bin/env ruby

require 'optparse'
require 'csv'

replaceGlyphs = {}

opt = OptionParser.new
opt.banner = "Usage: #{$0} [options] [filename...]"
opt.separator ""
opt.separator "Options:"
opt.on("-l", "--list-file=FILENAME", "Replacement list file (must be tab-separated)") { |val|
	replaceList = CSV.read(val, {:col_sep => "\t"})
	for glyph in replaceList
		replaceGlyphs[glyph[0]] = glyph[1]
	end
}
opt.on_tail("-h", "--help", "Show this message") {puts opt; exit}
opt.parse!(ARGV)

while l = gets
	l.chomp!
	glyphName = CSV.parse(l, {:col_sep => "\t"})[0][0]
	if replaceGlyphs.include?(glyphName) then
		print "#{glyphName}\t99:0:0:0:0:200:200:#{replaceGlyphs[glyphName]}:0:0:0\n"
	else
		print "#{l}\n"
	end
end
