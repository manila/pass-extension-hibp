#!/bin/bash

VERSION="0.0.1"

get_password() {
	$GPG -d "${GPG_OPTS[@]}" "$1.gpg" | head -n 1
}

get_pwned_password_list() {
	curl -s https://api.pwnedpasswords.com/range/$1 | awk -F ':' '{ print tolower($1) }'	
}

get_sha1() {
	echo -n $1 | openssl sha1 | awk '{ print tolower($2) }'
}

cmp_hashes() {
	echo "hi"
}

cmd_check_pwnage() {
	local_hash="$( get_sha1 $1 )"
	

	echo "$(get_pwned_password_list ${local_hash:0:5})" > remote_hashes_list

	readarray remote_hashes < remote_hashes_list

	for remote_hash in "${remote_hashes[@]}"; do
		if [ "${remote_hash:0:5}" == "${local_hash:5:5}" ]; then
			echo "Found in Pwned Passwords API"
		fi
	done
}

case "$1" in
	*) cmd_check_pwnage "$(get_password $@)";;
esac

exit 0
