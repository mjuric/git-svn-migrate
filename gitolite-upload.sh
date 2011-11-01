#!/bin/bash

for REPO in $(find $GIT_REPOS -name "*.git" -type d -exec basename {} .git \;); do
	REMOTE="$GIT_URL_ROOT_EXT""/${REPO//.//}"
	LOCAL="$GIT_REPOS/$REPO.git"
	echo -n "$LOCAL -> $REMOTE ..."

	(cd $LOCAL && git push --all --quiet "$REMOTE" && git push --tags --quiet "$REMOTE") || exit
	
	echo "Done."
done
