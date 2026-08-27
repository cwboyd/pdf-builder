
USAGE = <<~USAGE
  \n
  Usage: #{$0} <HASHSUM>

  Where HASHSUM is the filename of a textfile containing a HASH and a FILEPATH per line.
  This file is what duplicates are checked on.

  FILEPATH is allowed to contain spaces!

  HASH and FILEPATH must be separated by an asterisk literal, which can have leading and/or trailing whitespace.
    e.g:
      HASH1 * PATH1
      HASH2 * PATH2

  Some versions of the various hashing utils (e.g. MD5SUM, SHA1SUM, etc) reverse HASH and FILENAME.  If
  This is a problem for you, you can run the output thru the following Ruby snipped.

    ruby -ne "puts $_.strip.split(/\\s*\\*\\s*/).reverse.join(' * ')"

USAGE

multimap = Hash.new

def multimap.each_duplicated_file
  self.each_pair do |key, files|
    next unless files
    next unless files.length > 1
    yield key, files
  end
end

raise USAGE unless ARGV.length == 1
FILENAME = ARGV[0]
raise USAGE unless File.exist?(FILENAME)

File.open(FILENAME, "r") do |file|
  file.each_line do |line|
    hash, path = line.split(/\s*\*\s*/)
    path.chomp!
#    puts "hash #{hash} => #{path}"
    multimap[hash] ||= Array.new
    multimap[hash].push(path)
  end
end

multimap.each_duplicated_file do |key, files|
  puts "key #{key} was duplicated on files"
  files.each do |file|
    puts "\tFile: #{file}"
  end
  puts
end

