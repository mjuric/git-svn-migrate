#!/bin/bash
# Example usage: ./github-upload.sh mjuric/token:XXXXXX *.git

AUTH="$1"
shift

for LOCALREPO; do
	REPO=$(basename "$LOCALREPO" .git)
	URL="git@github.com:LSST/$REPO.git"
	printf "Uploading %s ===> %s\n" "$LOCALREPO" "$URL"

	# Delete existing repo with the same name
	# Note: I turned this off, because if the repo is already there, git push --force will overwrite it, and creation will (silently) fail
#	DELETE_TOKEN=$(curl -s -u "$AUTH"  http://github.com/api/v2/json/repos/delete/LSST/$REPO | sed 's/^{"delete_token":"\(.*\)"}$/\1/')
#	echo $DELETE_TOKEN | grep -q '^{"error":' || (echo -n "    Deleting existing: " && curl -s -u "$AUTH" -F "delete_token=$DELETE_TOKEN" http://github.com/api/v2/json/repos/delete/LSST/$REPO && echo && sleep 5)

	# Create new repo. The sleep 1 bit is because github sometimes fails to create the repo immediately.
	curl -s -u "$AUTH" -F "name=LSST/$REPO" -F "description=Repository for $REPO" http://github.com/api/v2/json/repos/create/ > /dev/null && sleep 1

	# Push the branches and tags upstream
	(cd $LOCALREPO && git push --quiet --force --all $URL && git push --quiet --force --tags $URL)
done
echo "Successfully completed."
