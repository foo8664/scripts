#!/usr/bin/env bash

# Stores already solved exercises
solved_dir=".solved"
LANGUAGES=(cpp c py) # Languages accepted, should be the file's extension

# $1 is the path to the file
compiles() {
	# Get's file's extension without a dot
	local extension="${1##*.}"
	local ret=0

	case "$extension" in
		"cpp")
			g++ -Wall -Werror -Wextra -std=c++20 -pedantic "$1" -o /dev/null
			ret="$?"
			;;
		"c")
			gcc -Wall -Werror -Wextra -std=c11 -pedantic "$1" -o /dev/null
			ret="$?"
			;;
	esac

	return "$ret"
}

cd "$HOME/code/study/neps/exercises"
rm -f a.out your_output.txt expected_output.txt input.txt teste.zip &>/dev/null

# LANGUAGES[@]/#/*. hsubstitutes each extension to *.<extension>
files="$(git status --porcelain "${LANGUAGES[@]/#/*.}" | grep '^??' | awk '-F ' '{print $2}')"
for file in $files; do
	# Ensure code at least compiles
	if ! compiles "$file"; then
		echo "'$file' does not compile, please fix it"
		continue
	fi

	# Removes trailing whitespace for convinence
	sed 's/\s*$//' <"$file" >"$solved_dir/$file"
	rm "$file"

	git add "$solved_dir/$file"
	git commit -m "Adding '$file'"
done

git push origin main
