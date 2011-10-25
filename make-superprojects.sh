#!/bin/bash

# Sanity test: For each repo, see if there are submodules
#for REPO in $(cat repos.txt | cut -d ' ' -f 1 | sort -r); do
#	RQ=$(echo $REPO | sed 's/\./\\./g')
#	grep -q "^$RQ\." repos.txt && echo "======= $REPO has submodules ======" || continue
#
#	for SUBMOD in $(cat repos.txt | grep "^$RQ\." | cut -d ' ' -f 1); do
#		SUBDIR=$(echo "$SUBMOD" | sed "s/^$REPO\.//" | sed 's/\./\//g')
#		SUBURL="git@github.com:LSST/$SUBMOD.git"
#		echo -e "\tAdding $SUBMOD ($SUBURL) -> $SUBDIR"
#	done
#done
#exit

REPOS="${1-repos.txt}"

# Get all packages that have subpackages
rm -f superprojects.txt
for REPODIR in $(cat $REPOS | cut -d ' ' -f 1 | cut -d . -f 1 | sort -u | sed 's/$/.git/'); do
	NSUBREPO=$(ls -d $(basename $REPODIR .git)*.git | wc | awk '{ print $1 }')
	test $NSUBREPO -ne 1 && echo $REPODIR >> superprojects.txt
done

URLROOT="git@github.com:LSST"
#URLROOT=$(pwd)

for REPODIR in $(cat superprojects.txt); do
	REPO=$(basename $REPODIR .git)
	URL="git@github.com:LSST/$REPO.git"
	printf "Making super-repo %s ===> %s\n" "$REPO" "$URL"
	
	rm -rf tmp-git-repo
	(mkdir tmp-git-repo && cd tmp-git-repo && git init) || exit
	(cp link-subdirs.sh tmp-git-repo && cd tmp-git-repo && git add link-subdirs.sh) || exit

	for SUBMOD in $(cat $REPOS | grep "^$REPO\." | cut -d ' ' -f 1 | sort); do
		SUBMOD=$(basename $SUBMOD .git)
		SUBDIR=$(echo "$SUBMOD" | sed "s/^$REPO\.//" | sed 's/\./\//g')
		SUBURL="$URLROOT/$SUBMOD.git"

		# Specials
		if [ "$SUBDIR" == "afw/extensions/rgb" ]; then
			SUBDIR=afw.subdirs/extensions/rgb
		fi
		if [ "$SUBDIR" == "catalogs/old_cat_code/catalogs/python/stars/throughputs" ]; then
			SUBDIR=catalogs/old_cat_code/catalogs/python/stars.subdirs/throughputs
		fi

		echo -e "\tAdding $SUBMOD ($SUBURL) -> $SUBDIR"
		(cd tmp-git-repo && mkdir -p $(dirname $SUBDIR) && git submodule --quiet add $SUBURL $SUBDIR) || exit
	done

	# Commit
	(cd tmp-git-repo && git commit --quiet -a --m "Superproject created") || exit

	# Clone to a bare repo
	(rm -rf $REPODIR && git clone --quiet --bare tmp-git-repo $REPODIR) || exit

	# Delete temp repo
	rm -rf tmp-git-repo
done;
