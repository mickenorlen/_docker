#!/bin/bash
# Run from postinit.sh
install() {
	cd $root
	sudo docker-compose run --rm web bundle install && rails new . --force --no-deps --database=postgresql
	cd -

	mkdir -p $root/$DOCKER_PATH/gem_data $root/$DOCKER_PATH/db_data
	echo "
# Docker
$DOCKER_PATH/db_data
$DOCKER_PATH/gem_data" >> $root/.gitignore
}

