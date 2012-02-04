#### Converting LSST SVN repos to git, a helper script ##
# We assume this script runs on git.lsstcorp.org
#
# All (detected) repos matching the $IMPORT_REPOS_REGEX pattern will be
# converted.
#
# Note: disabled automatic uploading to gitolite

die() { echo "$@"; exit 1; }

export SVN_REPOS=file:///lsst/repos
export GIT_REPOS=$HOME/lsst/git
export GIT_URL_ROOT="$GIT_REPOS"
export GIT_URL_ROOT_EXT="git@git.lsstcorp.org:"
export IMPORT_REPOS_REGEX="^(eups)$"

test -d $HOME/lsst || die "$HOME/lsst does not exist. Make it."
mkdir -p $HOME/lsst/repos $GIT_REPOS || die "Could not create $HOME/lsst/repos or $GIT_REPOS"

# Get list of packages to be converted
(svn list -R $SVN_REPOS | grep -e 'trunk/$' | grep -v '/tags/' | sed 's/\/trunk\/$//' | grep -v '/trunk/' | grep -E "$IMPORT_REPOS_REGEX" > $GIT_REPOS/package-list.txt) || die "Failed getting the package list"
# Flatten the hierarchy; convert '/' to '.'
perl -e 'while($_=<>) { chomp; $d=$_; $d =~ tr/\//./; print "$d '"$SVN_REPOS"'/$_\n"; }' $GIT_REPOS/package-list.txt  > $GIT_REPOS/repos.txt || die "Failed flattening the hierarchy"

# Get authors
./fetch-svn-authors.sh --authors-map=authors_map.txt --url-file=$GIT_REPOS/repos.txt > $GIT_REPOS/authors.txt || die "Failed fetching authors"

# Delete existing git repos
rm -rf $GIT_REPOS/*.git tmp-git-repo || die "Failed removing existing git repos"

# Migrate to git
./git-svn-migrate.sh --url-file=$GIT_REPOS/repos.txt --authors-file=$GIT_REPOS/authors.txt --no-metadata --destination=$GIT_REPOS 2>&1 | tee $GIT_REPOS/migration.log || die "git-svn-migrate failed"

# By-hand fixups
#(cd $GIT_REPOS/sims.catalogs.generation.git && git branch -m "tickets/#1794" "tickets/1794a") 	|| die "Fixups failed (Peter)"		# Peter's screwed up branch

# Upload to gitolite
#./gitolite-upload.sh || die "Upload to git@git.lsstcorp.org failed"
