#!/bin/bash

VERSION="0.0.1"

get_password() {
	$GPG -d "${GPG_OPTS[@]}" "$1.gpg" | head -n 1
}

get_pwned_password_list() {
	curl -s https://api.pwnedpasswords.com/range/$1 | awk -F ':' '{ print tolower($1) }'	
}

get_sha1() {
	echo "$1"
	shash="$(echo -n $1 | openssl sha1 | awk '{ print tolower($2) }')"
	echo "$(get_pwned_password_list ${shash:0:5})" > passlist
	readarray phasharr < passlist
	for phash in "${phasharr[@]}"; do
		if [ "${phash:0:5}" == "${shash:5:5}" ]; then
			echo "Found in Pwned Passwords API"
		fi
	done
}

cmp_hashes() {
	echo "hi"
}

case "$1" in
	*) get_sha1 "$(get_password $@)";;
esac

exit 0
