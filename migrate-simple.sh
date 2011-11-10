#!/bin/bash

for REPO in $@; do
	DEST="$GIT_REPOS/${REPO//\//.}.git"
	echo "$REPO -> $DEST"

	rm -rf tmp-repo-2
	git svn clone --quiet $SVN_REPOS/$REPO -A authors.txt --authors-prog=$PWD/svn-lookup-author.sh --no-metadata tmp-repo-2 || exit
	git init --bare $DEST || exit
	(cd tmp-repo-2 && git push --all $DEST) || exit
done
