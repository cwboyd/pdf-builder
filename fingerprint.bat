SETLOCAL ENABLEEXTENSIONS

:: This Ruby scriptlet swaps before and after the DELIM of ' * '.
SET __SWAP_COLS=ruby -ne "puts $_.strip.split(/\s*\*\s*/).reverse.join(' * ')"

:: This is the query we pass to findutils find ... it ignores .git and the various generated HASHSUM.txt files.
:: Fingerprinting the file we store fingerprints end would defeat the purpose of generating fingerprints to detect changes,
:: because they'd always change!
SET __FIND_QUERY=^\( -path "./.git" ^\) -prune -o -type f ! ^\( -iname "md5sum*.txt" -o -iname "sha1sum*.txt" -o -iname "sha256sum*.txt" ^\)

:: When we output, we'd like deterministic ordering based on the sorted filename.  But the various HASHSUM commands produce
:: 'HASH * PATH'.  To achieve this, we temporarily swap with DELIM, giving us 'PATH * HASH', then we pass the output
:: through sort.  But we'd like to have 'HASH * PATH' ultimately, because it's easier to read (and diff to see if the file changes).
:: So we swap the cols back - swap(swap(line)) == line (e.g. swap is its own inverse).
find . %__FIND_QUERY% -print0 | xargs -0 md5sum    | %__SWAP_COLS% | sort | %__SWAP_COLS% > MD5SUM.txt
find . %__FIND_QUERY% -print0 | xargs -0 sha1sum   | %__SWAP_COLS% | sort | %__SWAP_COLS% > SHA1SUM.txt
find . %__FIND_QUERY% -print0 | xargs -0 sha256sum | %__SWAP_COLS% | sort | %__SWAP_COLS% > SHA256SUM.txt

ENDLOCAL

