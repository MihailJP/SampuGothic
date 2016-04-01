#!/usr/bin/env ruby

require 'optparse'
require 'csv'

replaceGlyphs = {}
ignoreVersion = false

opt = OptionParser.new
opt.banner = "Usage: #{$0} [options] [filename...]"
opt.separator ""
opt.separator "Options:"
opt.on("-l", "--list-file=FILENAME", "Replacement list file (must be tab-separated, may be specified more than once)") { |val|
	replaceList = CSV.read(val, {:col_sep => "\t"})
	for glyph in replaceList
		replaceGlyphs[glyph[0]] = glyph[1]
	end
}
opt.on("-i", "--ignore-version", "Ignore glyph version") {
	ignoreVersion = true
}
opt.on_tail("-h", "--help", "Show this message") {puts opt; exit}
opt.parse!(ARGV)

while l = gets
	l.chomp!
	glyphName = CSV.parse(l, {:col_sep => "\t"})[0][0]
	glyphName2 = glyphName.dup
    if ignoreVersion then glyphName2.gsub!(/\@\d+/, "") end
	if replaceGlyphs.include?(glyphName2) then
		print "#{glyphName}\t99:0:0:0:0:200:200:#{replaceGlyphs[glyphName2]}:0:0:0\n"
	else
		print "#{l}\n"
	end
end
