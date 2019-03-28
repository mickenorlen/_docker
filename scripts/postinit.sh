#!/bin/bash
root='../..'
sampleDir='../samples'

case "$1" in
 rails) samples="$sampleDir/rails" ;;
 typo3) samples="$sampleDir/typo3" ;;
 *) echo "No samples for $1"; exit 1 ;;
esac


$(./utils.sh getEnv "$samples/root/.sample.env")

mkdir -p $root/$DOCKER_PATH

source $samples/install.sh
install;
