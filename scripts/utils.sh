#!/bin/bash
# Run in shell by ./utils.sh functionName

# Use by $(./utils.sh getEnv path/to/.env)
getEnv() {
	echo "eval $(egrep -v '^#' $1 | sed -e 's/ = /=/g' | xargs -0)"
}


# To enable running functions directly
# https://stackoverflow.com/questions/8818119/how-can-i-run-a-function-from-a-script-in-command-line
"$@"

