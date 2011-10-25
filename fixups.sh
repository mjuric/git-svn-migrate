#!/bin/bash

# Combine throughputs subrepo with sims.catalogs.old_cat_code.catalogs.python.stars.git
( test -d sims.catalogs.old_cat_code.catalogs.python.stars.throughputs.git && \
rm -rf tmp-git-repo && \
git clone sims.catalogs.old_cat_code.catalogs.python.stars.git tmp-git-repo && \
cd tmp-git-repo && \
git remote add -f A ../sims.catalogs.old_cat_code.catalogs.python.stars.throughputs.git && \
git merge -s ours --no-commit A/master && \
git read-tree --prefix=throughputs/ -u A/master && \
git commit -a -m "Merging throughputs subrepo into throughputs/" && \
git push && \
cd .. && rm -rf tmp-git-repo sims.catalogs.old_cat_code.catalogs.python.stars.throughputs.git && \
grep -v "sims\.catalogs\.old_cat_code\.catalogs\.python\.stars\.throughputs" repos.txt > repos.tmp && mv repos.tmp repos.txt \
)

# Rename DMS.afw.extensions.rgb to DMS.afw-extensions.rgb
( test -d DMS.afw.extensions.rgb.git && \
sed 's/^DMS\.afw\.extensions\.rgb/DMS.afw-extensions.rgb/' repos.txt > repos.tmp && mv repos.tmp repos.txt \
mv DMS.afw.extensions.rgb.git DMS.afw-extensions.rgb.git \
)

# TODO: Add extensions link to ../afw-extensions in afw
# Q: Is this a good idea? E.g., what if someone has afw-extensions and afw-extensions-rhl (as a temp dir)?
