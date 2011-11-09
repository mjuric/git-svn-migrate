#!/bin/bash

# Sanity test: For each repo, see if there are submodules
#for REPO in $(cat ""$GIT_REPOS/repos.txt"" | cut -d ' ' -f 1 | sort -r); do
#	RQ=$(echo $REPO | sed 's/\./\\./g')
#	grep -q "^$RQ\." "$GIT_REPOS/repos.txt" && echo "======= $REPO has submodules ======" || continue
#
#	for SUBMOD in $(cat "$GIT_REPOS/repos.txt" | grep "^$RQ\." | cut -d ' ' -f 1); do
#		SUBDIR=$(echo "$SUBMOD" | sed "s/^$REPO\.//" | sed 's/\./\//g')
#		SUBURL="git@github.com:LSST/$SUBMOD.git"
#		echo -e "\tAdding $SUBMOD ($SUBURL) -> $SUBDIR"
#	done
#done
#exit

REPOS="${1-$GIT_REPOS/repos.txt}"
URLROOT="${2-$GIT_URL_ROOT_EXT}"

# Get all packages that have subpackages
rm -f "$GIT_REPOS/superprojects.txt"
for REPODIR in $(cat $REPOS | cut -d ' ' -f 1 | cut -d . -f 1 | sort -u | sed 's/$/.git/'); do
	NSUBREPO=$(ls -d $GIT_REPOS/${REPODIR%.git}*.git | wc | awk '{ print $1 }')
	test $NSUBREPO -ne 1 && echo $REPODIR >> "$GIT_REPOS/superprojects.txt"
done

for REPODIR in $(cat "$GIT_REPOS/superprojects.txt"); do
	REPO=$(basename $REPODIR .git)
	URL="$URLROOT/$REPO.git"
	printf "Making super-repo %s ===> %s\n" "$REPO" "$URL"

	rm -rf tmp-git-repo
	(mkdir tmp-git-repo && cd tmp-git-repo && git init $SHARED_OPT) || exit
	(cp link-subdirs.sh tmp-git-repo && cd tmp-git-repo && git add link-subdirs.sh) || exit

	for SUBMOD in $(cat $REPOS | grep "^$REPO\." | cut -d ' ' -f 1 | sort); do
		SUBMOD=$(basename $SUBMOD .git)
		SUBDIR=$(echo "$SUBMOD" | sed "s/^$REPO\.//" | sed 's/\./\//g')
		SUBURL="$URLROOT/"${SUBMOD//.//}".git"

		# Specials
		if [ "$SUBDIR" == "afw/extensions/rgb" ]; then
			SUBDIR=afw.subdirs/extensions/rgb
		fi
		if [ "$SUBDIR" == "catalogs/old_cat_code/catalogs/python/stars/throughputs" ]; then
			SUBDIR=catalogs/old_cat_code/catalogs/python/stars.subdirs/throughputs
		fi
		echo "$SUBDIR" | grep -q "^CameraControl/"
		if [ $? -eq 0 ]; then
			SUBDIR=$(echo "$SUBDIR" | sed 's/^CameraControl\/\(.*\)$/CameraControl.subdirs\/\1/')
		fi

		echo -e "\tAdding $SUBMOD ($SUBURL) -> $SUBDIR"
		(cd tmp-git-repo && mkdir -p $(dirname $SUBDIR) && git submodule --quiet add $SUBURL $SUBDIR) || exit
	done

	# Commit
	(cd tmp-git-repo && git commit --quiet -a --m "Superproject created") || exit

	# Clone to a bare repo
	(rm -rf "$GIT_REPOS/$REPODIR" && git clone --quiet --bare tmp-git-repo "$GIT_REPOS/$REPODIR") || exit

	# Delete temp repo
	rm -rf tmp-git-repo
done;
