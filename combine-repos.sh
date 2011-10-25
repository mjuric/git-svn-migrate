#!/bin/bash
# combine-repos.sh <NEWREPO> <COMMONPREFIX> <REPO1> [<REPO2> <...>]
# Example: ./combine-repos.sh camera-CameraControl camera-CameraControl- camera-CameraControl-org-lsst-ccs*.git

script=`basename $0`;
dir=`pwd`/`dirname $0`;

NEW=$1
PREFIX=$2
shift
shift

# Create combined repo
test ! -f $NEW || { echo "Combined repo $NEW already exists."; exit -1; }
mkdir "$NEW" && ( cd "$NEW" && git init -q && touch README && git add README && git commit -q -a -m "New" )
NEW=`(cd "$NEW" && pwd)`
echo "Combined repository: $NEW"
exit

# Merge-in existig repos
for OLD; do
	OLD=`(cd "$OLD" && pwd)`
	SUBDIR=`basename $OLD .git`
	SUBDIR=`echo ${SUBDIR#$PREFIX} | sed 's/-/\//g'`
	BRANCH="svn/$SUBDIR"

	echo "====================================="
	echo "$OLD -> $SUBDIR";
	(cd $NEW && git fetch -q "$OLD" master:$BRANCH && $dir/merge-repo.sh $BRANCH $SUBDIR) &&
	(cd $NEW && git merge -q $BRANCH && git branch -D $BRANCH) || exit;
	echo "====================================="
done
echo "Successfully completed."
