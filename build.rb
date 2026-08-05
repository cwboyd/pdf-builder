
require 'combine_pdf'
load './sources.txt'

#
# Do some error checking.  Namely, your sources.txt must define OUTPUT_CORE_FILENAME
# and must have an array of string called SOURCES with at least 1 filename in it.
#

# Check and enforce OUTPUT_CORE_FILENAME
unless Object.const_defined?(:OUTPUT_CORE_FILENAME)
  raise NameError,
    "Missing 'OUTPUT_CORE_FILENAME' in sources.txt.\n\n" \
    "Purpose: This specifies the 'core' of the generated output PDF filename.  Keep in mind that this will be uploaded to\n" \
    "         staff who will end up with hundreds of application PDFs and it would be nice to make their lives easier so\n" \
    "         that when they look at them, they don't have to open and scroll through all of those applications.  I suggest\n" \
    "         including your NAME and STUDENTID in the filename.  The total file name will have a date stamp which alpha\n" \
    "         sorts correctly prepended and a suffix which is .py.pdf\n\n" \
    "Remedy: Please set this variable to your target output name (e.g., 'application-NAME-STUDENTID')."
end

# Check and enforce SOURCES existence
unless Object.const_defined?(:SOURCES)
  raise NameError,
    "Missing 'SOURCES' in sources.txt.\n\n" \
    "Purpose: This specifies an nonempty, ordered list of source PDF filenames to include/merge into the output file.\n\n" \
    "Remedy: Please define 'SOURCES' as a list of file path strings."
end

# Enforce structural requirements on SOURCES
# Access the global constant directly now that we know it exists
if !SOURCES.is_a?(Array) || SOURCES.empty?
  raise TypeError,
    "The 'SOURCES' variable in the module is invalid. " \
    "Remedy: Ensure 'SOURCES' is a populated list, e.g., SOURCES = ['file1.pdf']."
end

# Check if all items are strings
if !SOURCES.all? { |item| item.is_a?(String) }
  raise TypeError,
    "Invalid data inside the module's 'SOURCES' list. " \
    "Remedy: Ensure every element in the 'SOURCES' list is a string."
end

#
# Main body of script
#

merged_pdf = CombinePDF.new

SOURCES.each do |file|
  puts "Adding file '#{file}' ..."
  merged_pdf << CombinePDF.load(file)
end

# Calculate a name
current_datestamp = Time.now.strftime('%Y-%m-%d')
outfilename = "./output/" + current_datestamp + "-" + OUTPUT_CORE_FILENAME + ".rb.pdf"

# Rewrite the output of a single merged file.
puts "Saving to out file '#{outfilename}'."
merged_pdf.save(outfilename)


