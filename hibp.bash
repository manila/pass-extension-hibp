#!/bin/bash

VERSION="0.2.0"
AWK=awk

get_pwned_password_list() {
	echo "$(curl -s https://api.pwnedpasswords.com/range/$1 | $AWK '{ print tolower($1) }')"
}

get_sha1() {
	echo -n $1 | openssl sha1 | $AWK '{ print tolower($2) }'
}

cmd_check_pwnage() {
	if [[ -z $1 ]]; then
		msg="Usage: pass hibp [-a,--all] [pass-name]"
		die "$msg"
	elif [[ "$(cmd_show $1)" ]]; then
		pass="$(cmd_show $1)"
		local pass_hash="$( get_sha1 $pass )"
		pass_count=0
		local msg="Not found in Pwned Passwords Database"

		tmpdir 
		local tmpfile="$( mktemp $SECURE_TMPDIR/XXXXXX )"
	
		echo "$(get_pwned_password_list ${pass_hash:0:5})" > $tmpfile
	
		readarray remote_hashes < $tmpfile
	
		for remote_hash in "${remote_hashes[@]}"; do
			if [ "${remote_hash:0:5}" == "${pass_hash:5:5}" ]; then
				pass_count="$( echo ${remote_hash:36} | tr -d '\r\n')"
				msg="Oh no — pwned! \r
This password has been seen ${pass_count} time(s) before. \r
This password has previously appeared in a data breach and should never be used. \r
If you've ever used it anywhere before, change it!"
				break
			fi
		done
	
		rm -f remote_hashes_list
		echo -e "$msg"
	fi
}

yesno "Warning: This extensions sends your passwords to a third party API, if you agree to this and understand the potential risks enter Y"

case "$1" in
	*) cmd_check_pwnage $@;;
esac

exit 0
