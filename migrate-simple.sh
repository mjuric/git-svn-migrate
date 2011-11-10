#!/bin/bash

TMP=${TMP:-/tmp}
tmp_repo="$TMP/tmp-repo"

for REPO in $@; do
	DEST="$GIT_REPOS/${REPO//\//.}.git"
	echo "$REPO -> $DEST"

	rm -rf $tmp_repo
	git svn clone --quiet $SVN_REPOS/$REPO -A $GIT_REPOS/authors.txt --authors-prog=$PWD/svn-lookup-author.sh --no-metadata $tmp_repo || exit
	git init --bare $DEST || exit
	(cd $tmp_repo && git push --all $DEST) || exit
done

rm -rf $tmp_repo
