from datetime import datetime
import importlib.machinery
import importlib.util
import os
import pymupdf  # PyMuPDF handles both PDFs and Images natively

SOURCES_TXT = "./sources.txt"
MODULE_NAME = "sources" # module namespace to import array into.

# Force Python to read the text file as module code
loader = importlib.machinery.SourceFileLoader(MODULE_NAME, SOURCES_TXT)
spec = importlib.util.spec_from_file_location(MODULE_NAME, SOURCES_TXT, loader=loader)
sources = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sources)

#
# Do some error checking.  Namely, your sources.txt must define OUTPUT_CORE_FILENAME
# and must have an array of string called SOURCES with at least 1 filename in it.
#

# Check and enforce OUTPUT_CORE_FILENAME
if not hasattr(sources, "OUTPUT_CORE_FILENAME"):
    raise NameError(
        "Missing 'OUTPUT_CORE_FILENAME' in sources.txt.\n"
        "\n"
        "Purpose: This specifies the 'core' of the generated output PDF filename.  Keep in mind that this will be uploaded to\n"
        "         staff who will end up will hundreds of application PDFs and it would be nice to make their lives easier so\n"
        "         that when they look at them, they don't have to open and scroll through all of those applications.  I suggest\n"
        "         including your NAME and STUDENTID in the filename.  The total file name will have a date stamp which alpha\n"
        "         sorts correctly prepended and a suffix which is .py.pdf\n"
        "\n"
        "Remedy: Please set this variable to your target output name (e.g., 'application-NAME-STUDENTID')."
    )

print(f"sources.OUTPUT_CORE_FILENAME = {sources.OUTPUT_CORE_FILENAME}");

# Check and enforce SOURCES existence
if not hasattr(sources, "SOURCES"):
    raise NameError(
        "Missing 'SOURCES' in sources.txt.\n"
        "\n"
        "Purpose: This specifies an nonempty, ordered list of source PDF filenames to include/merge into the output file.\n"
        "\n"
        "Remedy: Please define 'SOURCES' as a list of file path strings."
    )

# Enforce structural requirements on SOURCES
if not isinstance(sources.SOURCES, list) or not sources.SOURCES:
    raise TypeError(
        "The 'SOURCES' variable in the module is invalid.\n"
        "\n"
        "Remedy: Ensure 'SOURCES' is a populated list, e.g., SOURCES = ['file1.pdf']."
    )

if not all(isinstance(item, str) for item in sources.SOURCES):
    raise TypeError(
        "Invalid data inside the module's 'SOURCES' list.\n"
        "\n"
        "Remedy: Ensure every element in the 'SOURCES' list is a string."
    )


#
# Main body of script
#

# Create an empty document acting as our merger container
merger = pymupdf.open()

for file in sources.SOURCES:
    # Get the file extension in lowercase
    _, ext = os.path.splitext(file.lower())

    # 1. If it's a PDF, merge it normally
    if ext == ".pdf":
        print(f"Adding PDF file '{file}' ...")
        with pymupdf.open(file) as src_doc:
            merger.insert_pdf(src_doc)

    # 2. If it's an image, create a page and insert it
    elif ext in [".png", ".jpg", ".jpeg", ".bmp", ".gif"]:
        print(f"Converting and adding image '{file}' ...")

        # Open the image file using PyMuPDF
        img_doc = pymupdf.open(file)

        # Convert the image into a temporary single-page PDF byte stream
        img_pdf_bytes = img_doc.convert_to_pdf()

        # Load those bytes as a PDF document object
        with pymupdf.open("pdf", img_pdf_bytes) as img_pdf:
            merger.insert_pdf(img_pdf)

    # 3. Fallback for unsupported formats
    else:
        raise(f"Error: Skipping '{file}'. Unsupported file format.")

# Calculate a name
current_datestamp = datetime.now().strftime("%Y-%m-%d")
outfilename = "./output/" + current_datestamp + "-" + sources.OUTPUT_CORE_FILENAME + ".py.pdf"

# Rewrite the output of a single merged file.
print(f"Saving to out file '{outfilename}'.")
merger.save(outfilename)
merger.close()

