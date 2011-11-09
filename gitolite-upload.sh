#!/bin/bash

GITOLITE='ssh git@git.lsstcorp.org'

for REPO in $(find $GIT_REPOS -name "*.git" -type d -exec basename {} .git \;); do
	RREPO="${REPO//.//}"
	REMOTE="$GIT_URL_ROOT_EXT""contrib/tmp/$RREPO"
	LOCAL="$GIT_REPOS/$REPO.git"
	echo -n "$LOCAL -> $REMOTE ... "

	# Test if remote repo exists, push to it if yes
	if $GITOLITE expand "^LSST/$RREPO$" | grep -q -E "LSST/$RREPO$"; then
		# Destination repo already exists; move it to contrib first
		echo -n "[note: $RREPO exists] ... "
		($GITOLITE sudo root mv "LSST/$RREPO" "contrib/tmp/$RREPO") || exit
	fi

	# Push to temporary repo in contrib/tmp
	(cd $LOCAL && git push --force --all --quiet "$REMOTE" && git push --force --tags --quiet "$REMOTE") || exit

	# Move it to final destination in LSST
	($GITOLITE sudo root mv "contrib/tmp/$RREPO" "LSST/$RREPO") || exit

	echo "Done."
done
