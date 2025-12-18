#!/usr/bin/env bash

# Displays the average time taken to execute a command
# Currently supported flags:
#	-t <n>:	Repeats the command <n> times, defaults to 5
#	-c:	Measures the CPU time instead (user + sys), default is real-time

declare -A FLAGS=( ["t"]=5 ["c"]="$(false)" )

# Function names cannot be ever confused as a real command, even if we don't
# directly use said command, the user might do so through the arguments.
#
# Initializes the flags in the FLAGS variable
__parse_flags() {
	OPTIND=1 # Just to make sure

	# Might consider disabling the POSIXLY_CORRECT variable temporarily
	while  getopts "t:c" FLAG $@; do
		if [[ "$FLAG" = ":" || "$FLAG" = "?" ]]; then
			exit 1
		elif [[ "$FLAG" = "--" ]]; then
			break
		fi

		# Checking if flags are valid
		if [[ "$FLAG" = "t" && "$OPTARG" =~ [^0-9] ]]; then
			echo "\"$FLAG\"'s argument must be a natural number"
			exit 1
		fi

		# Setting flags. Flags with arguments become true
		if [[ -n "$OPTARG" ]]; then
			FLAGS["$FLAG"]="$OPTARG"
		else
			FLAGS["$FLAG"]="$(true)"
		fi
	done
}

# Get's the time used by a command, assumes input is in the following format:
#real	X*mX.XXXs
#user	X*mX.XXXs
#sys	X*mX.XXXs
# simply put, it expects the stderr of a time command piped to `tail -n3.
# Returns an integer and a float, separated by space, representing the total
# minutes and seconds spent
__get_time() {
	__get_secs() { # Secs from X*mX.XXXs
		echo $1 | awk '-Fm' '{printf $2}' | sed 's/s//'
	}
	__get_mins() { #Mins from X*mX.XXXs
		echo $1 | awk '-Fm' '{printf $1}'
	}

	if [[ ( ${FLAGS["c"]} ) ]]; then # CPU time (user + sys)
		( read discarded_real )
		local user="$(read inp && echo $inp | awk '-F ' '{print $2}')"
		local sys="$(read inp && echo $inp | awk '-F ' '{print $2}')"

		printf '%d %.4lf' \
			"$(echo "$(__get_mins $user) + $(__get_mins $sys)" | bc -qs)" \
			"$(echo "$(__get_secs $user) + $(__get_secs $sys)" | bc -qs)"

	else # Real time
		real="$(read inp && echo $inp | awk '-F ' '{print $2}')"
		printf '%d %.4lf' "$(__get_mins $real)" "$(__get_secs $real)"
	fi
}

__repeat() {
	local repeat="${FLAGS["t"]}"
	local total_mins=0
	local total_secs=0

	while [[ "$repeat" -ne 0 ]]; do
		# Maybe this should use the portable format with `-p --`

		local val="$( ( time "${@:$OPTIND}" &>/dev/null ) |& tail -n3 |\
			__get_time)"

		total_mins="$(echo "$total_mins + $(echo $val | awk '-F ' \
				'{print $1}')" | bc -qs)"
		total_secs="$(echo "$total_secs + $(echo $val | awk '-F ' \
				'{print $2}')" | bc -qs)"

		repeat="$(($repeat - 1))"
	done

	printf '%dm%.4lfs\n'						\
		"$( echo $total_mins / ${FLAGS["t"]} | bc -qs )"	\
		"0$( echo 'scale=4;' $total_secs / ${FLAGS["t"]} | bc -qs )"
}

__parse_flags $@
__repeat $@
