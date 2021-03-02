#!/usr/bin/env bash
# 
# Genlog, changelog generator for skitOS commit rule
# Version 0.1.1
# By Wafelack <wafelack@protonmail.com>
# Licensed under the GNU General Public License version 3.0

set -euo pipefail

resolve_commit() {
	commit_type=$1
	commit_content=$2
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
	echo "$commit_type"
}

version_changelog() {
	declare -A sections

	COMMITS=$(git log --pretty=format:"%h" "${1}"..HEAD)

	for commit in $COMMITS
	do
		message=$(echo $(git log --format=%B -n 1 "$commit") | head -1)

		commit_type=$(echo "$message" | cut -f1 -d ':')
		commit_content=$(echo "$message" | cut -f2 -d ':')

		commit_type=$(resolve_commit "$commit_type" "$commit_content")

		if [ ${sections[$commit_type]+true} ]
		then
			sections[$commit_type]+="$commit_content\n"
		else
			sections[$commit_type]="$commit_content\n"
		fi
	done
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
}

full_changelog() {
	TAGS=$(git tag --list 2> /dev/null)
	PREVIOUS=$(git log --pretty=format:"%h" | tail -n 1)

	for tag in $TAGS
	do
		printf "## $tag\n\n"

		declare -A sections

		COMMITS=$(git log --pretty=format:"%h" "${PREVIOUS}".."${tag}")
		for commit in $COMMITS
		do
			message=$(echo $(git log --format=%B -n 1 "$commit") | head -1)

			commit_type=$(echo "$message" | cut -f1 -d ':')
			commit_content=$(echo "$message" | cut -f2 -d ':')

			commit_type=$(resolve_commit "$commit_type" "$commit_content")

			if [ ${sections[$commit_type]+true} ]
			then
				sections[$commit_type]+="$commit_content\n"
			else
				sections[$commit_type]="$commit_content\n"
			fi
			commit_content=""
			commit_type=""
		done
		COMMITS=""
		for section in "${!sections[@]}"
		do
			content=${sections[$section]}
			echo "### ${section^}"
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

			unset sections
		done


		PREVIOUS=$tag
	done	
}

TAG=0

if [[ $# == 1 ]]
then
	TAG=1
fi

if [[ $TAG == 1 ]]
then
	printf "# $1 - $(date +"%d/%m/%Y")\n\n"
	version_changelog "$1"
else
	printf "# CHANGELOG\n\n"
	full_changelog
fi
