#!/bin/bash

VERSION="0.1.0"

get_password() {
	$GPG -d "${GPG_OPTS[@]}" "$PREFIX/$1.gpg" | head -n 1
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
	found_msg="Not found in Pwned Passwords Database"

	echo "$(get_pwned_password_list ${local_hash:0:5})" > remote_hashes_list

	readarray remote_hashes < remote_hashes_list

	for remote_hash in "${remote_hashes[@]}"; do
		if [ "${remote_hash:0:5}" == "${local_hash:5:5}" ]; then
			found_msg="Found in Pwned Passwords Database"
		fi
	done

	echo $found_msg
}

case "$1" in
	*) cmd_check_pwnage "$(get_password $@)";;
esac

exit 0
