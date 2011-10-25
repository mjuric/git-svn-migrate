#!/bin/bash
# Example usage: ./github-delete.sh mjuric/token:XXXXXX ["Camera."]
# WARNING: If the second pattern is not given, this will nuke _all_ repositories

AUTH="$1"
PATTERN=${2-.}

for REPO in $(curl -s -u "$AUTH" http://github.com/api/v2/json/repos/show/LSST/ | jsonpretty | grep name | cut -d : -f 2 | sed -e 's/"\|,\| //g' | grep "$PATTERN"); do
	echo -n "Deleting $REPO from github ... "

	# Delete existing repo with the same name
	# Note: I turned this off, because if the repo is already there, git push --force will overwrite it, and creation will (silently) fail
	DELETE_TOKEN=$(curl -s -u "$AUTH"  http://github.com/api/v2/json/repos/delete/LSST/$REPO | sed 's/^{"delete_token":"\(.*\)"}$/\1/')
	(echo $DELETE_TOKEN | grep -q '^{"error":') && echo " ERROR." || (curl -s -u "$AUTH" -F "delete_token=$DELETE_TOKEN" http://github.com/api/v2/json/repos/delete/LSST/$REPO && echo)

done
echo "Successfully completed."
