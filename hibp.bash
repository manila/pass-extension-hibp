#!/bin/bash

VERSION="0.1.1"
AWK=awk

get_pwned_password_list() {
	echo "$(curl -s https://api.pwnedpasswords.com/range/$1 | $AWK -F ':' '{ print tolower($1) }')"
}

get_sha1() {
	echo -n $1 | openssl sha1 | awk '{ print tolower($2) }'
}

cmd_check_pwnage() {
	if [[ -z "$1" ]]; then
		msg="Error: No passfile specified."
		die "$msg"
	elif [[ "$(cmd_show $1)" ]]; then
		pass="$(cmd_show $1)"
		local pass_hash="$( get_sha1 $pass )"
		local msg="Not found in Pwned Passwords Database"

		tmpdir 
		local tmpfile="$( mktemp $SECURE_TMPDIR/XXXXXX )"
	
		echo "$(get_pwned_password_list ${pass_hash:0:5})" > $tmpfile
	
		readarray remote_hashes < $tmpfile
	
		for remote_hash in "${remote_hashes[@]}"; do
			if [ "${remote_hash:0:5}" == "${pass_hash:5:5}" ]; then
				msg="Found in Pwned Passwords Database"
			fi
		done
	
		rm -f remote_hashes_list
		echo $msg
	fi
}

yesno "Warning: This extensions sends your passwords to a third party API, if you agree to this and understand the potential risks enter Y"

case "$1" in
	*) cmd_check_pwnage $@;;
esac

exit 0
