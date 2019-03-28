#!/bin/bash
echo $1
root='../..'
sampleDir='../samples'

case "$1" in
 rails) samples="$sampleDir/rails" ;;
 typo3) samples="$sampleDir/typo3" ;;
 *) echo "No samples for $1"; exit 1 ;;
esac


$(./utils.sh getEnv "$samples/root/.sample.env")

# mkdir -p $root/$DOCKER_PATH

# Soft copy root samples
for rootFile in $(find $samples/root -maxdepth 1 -type f -exec basename {} \;); do
	cp -n "$samples/root/$rootFile" "$root/${rootFile//sample./}";
done;
# Soft copy docker samples
for dockerFile in $(find $samples/docker -maxdepth 1 -type f -exec basename {} \;); do
	cp -n "$samples/docker/$configFile" "$root/$DOCKER_PATH/${configFile//sample./}";
done;

source $samples/install.sh
install;
