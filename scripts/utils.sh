#!/bin/bash
# Run in shell by ./utils.sh functionName

# Use by $(./utils.sh parseEnv path/to/.env)
parseEnv() {
	echo "eval $(egrep -v '^#' $1 | sed -e 's/ = /=/g' | xargs -0)"
}

cpSamples() {
	from=$1; to=$2
	for file in $(find $from -maxdepth 1 -type f -exec basename {} \;); do
		cp -n "$from/$file" "$to/${file//sample./}";
	done;
}

splitString() { # arg1 = string, arg2 = delimiter, arg3 = return index
	IFS=$2 read -r -a array <<< "$1"
	echo "${array[$3]}"
}


# To enable running functions directly
# https://stackoverflow.com/questions/8818119/how-can-i-run-a-function-from-a-script-in-command-line
"$@"

