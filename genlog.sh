#!/usr/bin/env bash
set -euo pipefail

# Changelog Generator for the skiftOS commit rule, v0.1.0
# By Wafelack <wafelack@protonmail.com>.
# License under the GNU General Public License v3.0.

if [[ $# != 2 ]]
then
  >&2 echo "Usage: genlog.sh <commit> <version>."
  exit -1
fi

COMMITS=$(git log --pretty=format:"%h" ${1}..HEAD)

declare -A sections

for commit in $COMMITS
do
  message=$(echo $(git log --format=%B -n 1 $commit) | head -1)

  commit_type=$(echo $message | cut -f1 -d ':')
  commit_content=$(echo $message | cut -f2 -d ':')

  if [[ -z $commit_type ]] || [[ -z $commit_content ]]
  then
    >&2 echo "\tIgnoring invalid commit: \`$message\`"
    continue
  fi

  if [[ $commit_type == "kenrel" ]]
  then
    commit_type="kernel"
  elif [[ $commit_type == "ci" ]]
  then
     commit_type="CI"
  fi

  if [ ${sections[$commit_type]+true} ]
  then
    sections[$commit_type]+="$commit_content\n"
  else
    sections[$commit_type]="$commit_content\n"
  fi
done

echo "# $2 - $(date +"%d/%m/%Y")"
echo

for section in "${!sections[@]}"
do
  content=${sections[$section]}
  echo "## ${section^}"
  echo
  printf "* "

  prev_newline=0

  for (( i=0; i<${#content}; i++ ))
  do
     char="${content:$i:1}"
     following=$i+1
     following_char="${content:$following:1}"

     if [ "$char" = $'\\' ] && [ "$following_char" = $'n' ]
     then
       echo
       i=$i+1
       prev_newline=1
     else
      if [[ $prev_newline == 1 ]]
      then
        prev_newline=0
        printf "* "
      fi

      printf "%s" "${char}"

     fi
  done
  echo
done
