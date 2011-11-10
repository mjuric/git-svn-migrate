######## Converting LSST SVN repos to git, a helper script
# We assume ~/lsst exists, is writable, and is on a local
# filesystem (otherwise the conversion will be very slow)
#
# The temporary repositories are created in $TMP (defaults
# to /tmp if $TMP not defined)

die() { echo "$@"; exit 1; }

export SVN_REPOS=file://$HOME/lsst/repos
export GIT_REPOS=$HOME/lsst/git
export GIT_URL_ROOT="$GIT_REPOS"
export GIT_URL_ROOT_EXT="git@git.lsstcorp.org:"
export IMPORT_REPOS_REGEX="^(DMS|Trac|GilTest|comparisons|contrib|eups|vendor)"

test -d $HOME/lsst || die "$HOME/lsst does not exist. Make it."
mkdir -p $HOME/lsst/repos $GIT_REPOS || die "Could not create $HOME/lsst/repos or $GIT_REPOS"

# rsync the SVN repositories (make them local)
rsync -avz svn.lsstcorp.org:/lsst/repos $HOME/lsst || die "Failed rsyncing"

# Get list of packages to be converted
(svn list -R $SVN_REPOS | grep -e 'trunk/$' | grep -v '/tags/' | sed 's/\/trunk\/$//' | grep -v '/trunk/' | grep -E "$IMPORT_REPOS_REGEX" > $GIT_REPOS/package-list.txt) || die "Failed getting the package list"
# Flatten the hierarchy; convert '/' to '.'
perl -e 'while($_=<>) { chomp; $d=$_; $d =~ tr/\//./; print "$d '"$SVN_REPOS"'/$_\n"; }' $GIT_REPOS/package-list.txt  > $GIT_REPOS/repos.txt || die "Failed flattening the hierarchy"

# Get authors
./fetch-svn-authors.sh --url-file=$GIT_REPOS/repos.txt > $GIT_REPOS/authors.txt || die "Failed fetching authors"

# Delete existing git repos
rm -rf $GIT_REPOS/*.git tmp-git-repo || die "Failed removing existing git repos"

# Migrate to git
./git-svn-migrate.sh --url-file=$GIT_REPOS/repos.txt --authors-file=$GIT_REPOS/authors.txt --no-metadata --destination=$GIT_REPOS 2>&1 | tee $GIT_REPOS/migration.log || die "git-svn-migrate failed"

# Migrate "simple" repos (those not having stdlayout)
./migrate-simple.sh DMS/report/Dc2Report DMS/report/reportDC3a contrib/STOMP contrib/bp || die "Simple repo migration failed"

# By-hand fixups
#(cd $GIT_REPOS/sims.catalogs.generation.git && git branch -m "tickets/#1794" "tickets/1794a") 	|| die "Fixups failed (Peter)"		# Peter's screwed up branch
mv $GIT_REPOS/DMS.meas.multifitData.git $GIT_REPOS/DMS.testdata.multifit.git			|| die "Fixups failed (multifit)"	# Relocate multifitData

# Upload to gitolite
./gitolite-upload.sh || die "Upload to git@git.lsstcorp.org failed"
