#!/bin/bash

VERSION="0.1.1"

get_pwned_password_list() {
	curl -s https://api.pwnedpasswords.com/range/$1 | awk -F ':' '{ print tolower($1) }'	
}

get_sha1() {
	echo -n $1 | openssl sha1 | awk '{ print tolower($2) }'
}

cmd_check_pwnage() {
	if [[ -z "$1" ]]; then
		msg="Please enter the name of a password file to check"
		die "$msg"
	elif [[ "$(cmd_show $1)" ]]; then
		pass="$(cmd_show $1)"
		local pass_hash="$( get_sha1 $pass )"
		local msg="Not found in Pwned Passwords Database"
	
		echo "$(get_pwned_password_list ${pass_hash:0:5})" > remote_hashes_list
	
		readarray remote_hashes < remote_hashes_list
	
		for remote_hash in "${remote_hashes[@]}"; do
			if [ "${remote_hash:0:5}" == "${local_hash:5:5}" ]; then
				msg="Found in Pwned Passwords Database"
			fi
		done
	
		echo $msg
	fi
}


case "$1" in
	*) cmd_check_pwnage $@;;
esac

exit 0
