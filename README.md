
This project is used to build a composite-PDF from a set of sources PDFs.

The output will be a single PDF file saved in the ./output directory with a date-stamped format of YYYY-MM-DD-filename.pdf
based on the current date.

There are 2 scripts that facilitate this:

# build.py

    python -r requirements.txt
    python build.py

# build.rb

    bundle install
    bundle exec ruby build.rb


# sources.mak

This file contains data structures using subset of Ruby and Python that is compatible and eval'd into the respective
scripts.  Edit this file to change the sources and output.  The file contains comments documenting how this works.

# Also note: windows-transfer-scripts

This project contains portions of https://github.com/cwboyd/windows-transfer-scripts to facility fingerprinting and
archiving of sources and generated output, and copies over from that README:

These are simple batch files used with git and robocopy
to detect bit rot (and changes) plus keep a target updated.  This __does not__
stick the files in the git repo, since that would double storage.  It does
not use git-annex or GVFS, since that adds unnecessary complexity.

fingerprint.bat updates the hashes.  Both MD5 and SHA1 are used, since the
liklihood of producing a collision with 2 different hash functions is lower.

transfer.bat transfers from this directory to a target directory.  You will
have to edit this batch file to change \_\_TARGET.

# FAQ

## How do I get started?

1. Clone this repo into an empty directory - via `git clone https://github.com/cwboyd/pdf-builder`.

2. Run 'force_no_push.bat' so that you don't accidentally push your private docs to a public repo!

3. Copy your source documents into ./sources

4. Edit source.txt to include then in the SOURCES array, in whatever order you wish.

5. Update OUTPUT_CORE_FILENAME to be the stem filename you want.

Then run whichever build.py / build.rb script you wish.  Your output should be in a file with a name
like:

    ./output/YYYY-MM-DD-${OUTPUT_CORE_FILENAME}.pdf


