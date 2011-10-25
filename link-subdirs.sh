#!/bin/bash
# Link all subdirectories from .subdir directories to where they belong

# Note: this hasn't been tested in more complex cases, like .subdir within a .subdir

for SDIR in $(find . -name '*.subdirs'); do
	BASE=${SDIR%%.subdirs}
	test ! -d "$BASE"
	for SUBDIR in $(find "$SDIR" -maxdepth 1 -mindepth 1 -type d); do
		REL=$(basename $SDIR)"/"$(basename "$SUBDIR")
		cd $BASE && ln -sf ../$REL
	done
done
