require 'hexapdf'
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

# Calculate a name
current_datestamp = Time.now.strftime('%Y-%m-%d')
outfilename = "./output/" + current_datestamp + "-" + OUTPUT_CORE_FILENAME + ".rb.pdf"


#
# Main body of script
#

# Initialize the Composer without an automatic default page so our loops control
# page sizes cleanly right from page one.
HexaPDF::Composer.new(skip_page_creation: true) do |composer|
  SOURCES.each do |file|
    ext = File.extname(file).downcase

    # 1. Handle standard PDF file
    if ext == '.pdf'
      puts "Adding PDF file '#{file}' ..."
      source_pdf = HexaPDF::Document.open(file)

      source_pdf.pages.each do |pdf_page|
        # Register the external file references into our output context
        imported_page = composer.document.import(pdf_page)
        box = imported_page.box

        # Calculate dynamic page frame boundaries in points
        width  = box.right - box.left
        height = box.top - box.bottom

        # Define a dynamic style profile targeting these specific dimensions
        composer.page_style(:custom_pdf, page_size: [0, 0, width, height])

        # Deploy a clean new page utilizing our dynamic sizing profile
        composer.new_page(:custom_pdf)

        # Convert the page wrapper into a raw layout form object so xobject
        # renders it as vectors instead of routing it to the image loader!
        form_xobject = imported_page.to_form_xobject

        # Draw the vector object at the exact bottom-left corner
        composer.page.canvas.xobject(form_xobject, at: [0,0])
      end

    # 2. Handle Image formats natively
    elsif ['.png', '.jpg', '.jpeg', '.bmp', '.gif'].include?(ext)
      puts "Converting and adding image '#{file}' ..."

      # 1. Force a strict standard Letter page layout configuration
      composer.page_style(:standard_letter, page_size: :Letter)

      # 2. ALWAYS force a clean, dedicated new page for this specific image
      # to prevent any formatting rules from the previous files from bleeding in.
      composer.new_page(:standard_letter)

      # 3. Specify the width limits directly as method arguments.
      # Leaving the height completely out forces the composer to auto-calculate
      # the height proportionally so it never deforms or stretches your photos!
      # (540 points matches the printable area width of a standard Letter page)
      composer.image(file, width: 540)

    # 3. Handle unsupported extensions safely
    else
      puts "⚠️ Warning: Skipping '#{file}'. Unsupported file format."
    end
  end

  # Ensure the completed data stream writes safely out to your deployment location
  puts "Saving to out file '#{outfilename}'."
  composer.write(outfilename)
end

