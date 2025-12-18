#!/usr/bin/env bash

# Reads a number in decimal, octal, hexadecimal, or binary as it's first and
# only argument, print's all of the above bases for it
#
# $1 must be in one of the following formats
# 0x<hexa>
# 0o<octal>
# 0b<binary>
# <decimal> (both a-f and A-f are valid)
# not respecting it will result in an error
#

# $1 is the global $1, returns "16", "10", "8", or "2"
getibase() {
	if [[ $(echo "$1" | cut -c1) != "0" ]]; then
		echo "10"
		return;
	fi

	case $(echo "$1" | cut -c2) in
	"x")
		echo "16"
		;;
	"o")
		echo "8"
		;;
	"b")
		echo "2"
		;;
	esac
}

num="$1"
ibase="$(getibase "$num")"

# bc only takes hexadecimals with upper case numbers
if [[ "$ibase" = "16" ]]; then
	num="$(echo "$num" | tr 'a-f' 'A-F')"
fi
# bc does not recognize 0<letter> prefixes
if [[ "$ibase" != "10" ]]; then
	num="$(echo $num | cut -c3- )"
fi

printf "hex 0x%s\n"	"$(echo "obase=16; ibase=$ibase; $num" | bc  |
			tr 'a-z' 'A-Z' | sed 's/^ //')"
printf "dec %s\n"	"$(echo "ibase=$ibase; $num" | bc )"
printf "oct 0o%s\n"	"$(echo "obase=8; ibase=$ibase; $num" | bc )"
printf "bin 0b%s\n"	"$(echo "obase=2; ibase=$ibase; $num" | bc )"
