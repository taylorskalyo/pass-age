#!/usr/bin/env bash
# pass age - Password Store Extension (https://www.passwordstore.org/)
# Copyright (C) 2018 taylorskalyo.
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

readonly VERSION="0.1"

cmd_age_version() {
	cat <<-_EOF
	$PROGRAM $COMMAND $VERSION
	_EOF
}

cmd_age_usage() {
	cmd_age_version
	echo
	cat <<-_EOF
	Usage:
	     $PROGRAM age [-h] pass-names
	         Display the age of passwords based on their last commit time
	         in the pass git repository.
	Options:
	     --version        Show version information.
	     -h, --help       Print this help message and exit.
	
	     PASSWORD_STORE_AGE_CRITICAL
	                      Age in seconds before highlighting in red.
	                      Default is 31536000 (1 year).
	     PASSWORD_STORE_AGE_WARN
	                      Age in seconds before highlighting in yellow.
	                      Default is 15552000 (180 days).
	_EOF
}

PASSWORD_STORE_AGE_CRITICAL=${AGE_CRITICAL:-31536000}
PASSWORD_STORE_AGE_WARN=${AGE_WARN:-15552000}

_show_age() {
	local path="$1"
	local maxlen=$2
	local age ct dir color name
	local red='\033[1;31m'
	local green='\033[1;32m'
	local yellow='\033[1;33m'
	local blue='\033[1;34m'
	local reset='\033[0m'
	ct="$(cmd_git log -1 --pretty=format:"%ct" "$path" 2>/dev/null)"
	if [[ -n $ct ]] && [ $(( $(date +%s) - ct)) -gt $PASSWORD_STORE_AGE_CRITICAL ]; then
		color="${red}"
	elif [[ -n $ct ]] && [ $(( $(date +%s) - ct)) -gt $PASSWORD_STORE_AGE_WARN ]; then
		color="${yellow}"
	else
		color="${green}"
	fi
	age="$(cmd_git log -1 --pretty=format:"%cr" "$path" 2>/dev/null)"
	if [[ -d $path ]]; then
		dir="${blue}"
	fi
	name="${path##*/}"
	if [[ -z $age ]]; then
		printf "%s\n" "${name%.gpg}"
	else
		printf "$dir%-${maxlen}s$color%s$reset\n" "${name%.gpg}" "$age"
	fi
}

cmd_age() {
	local path="$1"
	local passfile="$PREFIX/$path.gpg"
	local maxlen=0
	local name
	check_sneaky_paths "$path"
	if [[ -f $passfile ]]; then
		name="${passfile##*/}"
		_show_age "$passfile" ${#name}
	elif [[ -d $PREFIX/$path ]]; then
		for subpath in $PREFIX/$path/*; do
			check_sneaky_paths "$subpath"
			name="${subpath##*/}"
			if [ ${#name} -gt $maxlen ]; then
				maxlen=${#name}
			fi
		done
		for subpath in $PREFIX/$path/*; do
			_show_age "$subpath" $maxlen
		done
	elif [[ -z $path ]]; then
		die "Error: password store is empty. Try \"pass init\"."
	else
		die "Error: $path is not in the password store."
	fi
}

# Getopt options
opts="$($GETOPT -o "h" -l "help,version" -n "$PROGRAM $COMMAND" -- "$@")"
err=$?
eval set -- "$opts"
while true; do case $1 in
	-h|--help) shift; cmd_age_usage; exit 0 ;;
	--version) shift; cmd_age_version; exit 0 ;;
	--) shift; break ;;
esac done

[[ $err -ne 0 ]] && cmd_age_usage && exit 1
cmd_age "$@"
