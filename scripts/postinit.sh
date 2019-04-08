#!/bin/bash
root="$(pwd)/../.."
sampleDir="$(pwd)/../samples"
scripts="$(pwd)"

case "$1" in
 rails) samples="$sampleDir/rails" ;;
 elixir) samples="$sampleDir/elixir" ;;
 wordpress) samples="$sampleDir/wordpress" ;;
 *) echo "No samples for $1"; exit 1 ;;
esac


$(./utils.sh getEnv "$samples/root/.sample.env")

mkdir -p $root/_docker

source $samples/install.sh
install;
