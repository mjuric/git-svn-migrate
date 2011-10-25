#!/bin/bash
# MUST BE CALLED FROM DESTINATION REPO

BRANCH_NAME=$1
SUBDIR_NAME=$2

REVRANGE=`git log $BRANCH_NAME --pretty=oneline | tail -n 1 | head -n 1 | cut -f 1 -d' '`..$BRANCH_NAME
echo "Rev range:" $REVRANGE
git filter-branch -f --index-filter \
    'git ls-files -s | \
        sed "s-\t-&'"$SUBDIR_NAME"'/-" | \
        GIT_INDEX_FILE=$GIT_INDEX_FILE.new git update-index --index-info && \
        (test -f $GIT_INDEX_FILE.new && mv $GIT_INDEX_FILE.new $GIT_INDEX_FILE || echo " Note: detected a directory move.")
    ' "$REVRANGE"
