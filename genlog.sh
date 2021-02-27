#!/usr/bin/env bash
set -euo pipefail

# Genlog v0.1.0, a changelog generator.
# By Wafelack <wafelack@protonmail.com>.
# License under the GNU General Public License v3.0.

if [[ $# != 2 ]]
then
  >&2 echo "Usage: genlog.sh <commit>."
  exit -1
fi

HASHES=$(git log --pretty=format:"%h" )
