#!/bin/bash
# Run from postinit.sh
install() {
	data=$root/_docker/data
	mkdir -p $data/db $data/home $data/mix $data/hex

# 	# Soft copy samples
	$(./utils.sh cpSamples "$samples/root" "$root");
	$(./utils.sh cpSamples "$samples/docker" "$root/_docker");
	# $(./utils.sh cpSamples "$samples/home" "$data/home");


	cd $root

	# Update .env
	echo -n "Edit .env: APP_NAME/BUILD_IMAGE [enter]"
	read waiting
	$($scripts/utils.sh getEnv "$root/.env")

	# Install elixir
	export CURRENT_UID=$(id -u):$(id -g);
	echo -e "\nGetting $BUILD_IMAGE locally, trying pull from docker hub or falling back to _docker/Dockerfile...\n"
	yarn d hasImages 2>/dev/null || sudo -E docker-compose pull web || yarn d rebuild
	sudo -E docker-compose run --no-deps --rm --user 0 web bash -c "chown $CURRENT_UID /home/docker"
	sudo -E docker-compose run --no-deps --rm web bash -c "mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install hex phx_new $PHOENIX_VERSION --force && \
		mix hex.info && \
		echo Y | mix phx.new . && \
		mix deps.get && \
		cd assets && yarn install"


	# Fix db host
	sed -i '/hostname:/c\  hostname: \"db\",' $root/config/dev.exs
	yarn d start

	# Add to gitignore
	echo "
# Docker
_docker/data
!_docker/data/home
_docker/data/home/**
!_docker/data/home/.bashrc" >> $root/.gitignore

	# Create db
	sudo -E docker-compose run --no-deps --rm web bash -c "mix ecto.create"

	echo -e "\nDone! Phoenix at http://localhost:4000"
}

