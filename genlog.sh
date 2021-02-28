#!/usr/bin/env bash
set -euo pipefail


TAG=0

if [[ $# == 1 ]]
then
  TAG=1
fi


if [[ $TAG == 1 ]]
then
  if [[ "$1" == "help" ]]
  then
    echo "Genlog is a changelog generator for the skiftOS commit rule."
    echo "Version 0.1.1"
    echo "By Wafelack <wafelack@protonmail.com>."
    echo "License under the GNU General Public License v3.0."
    echo "Usage: genlog.sh [tag]"
    exit
  fi
fi

if [[ $TAG == 1 ]]
then
  COMMITS=$(git log --pretty=format:"%h" "${1}"..HEAD)
else
  COMMITS=$(git log --pretty=format:"%h")
fi

declare -A sections

for commit in $COMMITS
do
  message=$(echo $(git log --format=%B -n 1 "$commit") | head -1)

  commit_type=$(echo "$message" | cut -f1 -d ':')
  commit_content=$(echo "$message" | cut -f2 -d ':')

  if [[ -z $commit_type ]] || [[ -z $commit_content ]]
  then
    >&2 printf "\tIgnoring invalid commit: \`$message\`\n"
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

if [[ $TAG == 1 ]]
then
  echo "# $1 - $(date +"%d/%m/%Y")"
else
  echo "# CHANGELOG"
fi
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
