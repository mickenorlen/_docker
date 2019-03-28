#!/bin/bash
# Run in shell by ./utils.sh functionName

# Use by $(./utils.sh getEnv path/to/.env)
getEnv() {
	echo "eval $(egrep -v '^#' $1 | sed -e 's/ = /=/g' | xargs -0)"
}

cpSamples() {
	from=$1; to=$2
	for file in $(find $from -maxdepth 1 -type f -exec basename {} \;); do
		cp -n "$from/$file" "$to/${file//sample./}";
	done;
}


# To enable running functions directly
# https://stackoverflow.com/questions/8818119/how-can-i-run-a-function-from-a-script-in-command-line
"$@"

