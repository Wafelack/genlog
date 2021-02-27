#!/usr/bin/env bash
set -euo pipefail

# Genlog v0.1.0, a changelog generator.
# By Wafelack <wafelack@protonmail.com>.
# License under the GNU General Public License v3.0.

if [[ $# != 1 ]]
then
  >&2 echo "Usage: genlog.sh <commit>."
  exit -1
fi

COMMITS=$(git log --pretty=format:"%h" ${1}..HEAD)
echo $COMMITS

for commit in $COMMITS
do
  message=$(echo $(git log --format=%B -n 1 $commit) | head -1)
  
  echo "${commit} - ${message}"  
done
