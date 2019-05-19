#!/bin/bash
# Run from postinit.sh
install() {
	data=$root/_docker/data
	mkdir -p $data/db $data/home

	# Soft copy samples
	$(./utils.sh cpSamples "$samples/root" "$root");
	$(./utils.sh cpSamples "$samples/docker" "$root/_docker");
	$(./utils.sh cpSamples "$samples/home" "$data/home");


	cd $root

	# Update .env
	echo -n "Edit .env [enter]"
	read waiting
	$($scripts/utils.sh getEnv "$root/.env")
	# Install rails
	export CURRENT_UID=$(id -u):$(id -g);
	echo -e "\nGetting $BUILD_IMAGE locally, pulling from hub or falling back to _docker/Dockerfile...\n"
	yarn d hasImages 2>/dev/null || sudo -E docker-compose pull web || yarn d rebuild

	# Add to gitignore
	echo "
# Docker
_docker/data" >> $root/.gitignore

	# Insert scripts to package.json
	sed -i -e "/\"private\"/r $samples/postinstall/package.json.script.txt" $root/package.json
	yarn d start

	echo -e "\nDone! Wordpress at http://localhost:8000"
}
