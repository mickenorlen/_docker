#!/bin/bash
cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";
# Make sure submodule is up to date
git checkout master && git pull
# Then run possibly updated postinit
./postinit.sh $1
