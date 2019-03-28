#!/bin/bash
# Run from postinit.sh
install() {
	data=$root/$DOCKER_PATH/data
	mkdir -p $data/db $data/home $data/bundle

	# Soft copy samples
	$(./utils.sh cpSamples "$samples/root" "$root");
	$(./utils.sh cpSamples "$samples/docker" "$root/$DOCKER_PATH");
	$(./utils.sh cpSamples "$samples/home" "$data/home");

	# Install rails
	export CURRENT_UID=$(id -u):$(id -g);
	cd $root
	sudo -E docker-compose run --no-deps --rm --user 0 web bash -c "chown $CURRENT_UID /home/docker"
	sudo -E docker-compose run --no-deps --rm web bash -c "bundle install && bundle exec rails new . --force -B --database=postgresql && bundle update"
	cd -

	# Add to gitignore
	echo "
# Docker
$DOCKER_PATH/data
!$DOCKER_PATH/data/home
$DOCKER_PATH/data/home/.bundle" >> $root/.gitignore

	# Insert scripts to package.json
	sed -i -e "/\"private\"/r $samples/postinstall/package.json.script.txt" $root/package.json
	# Insert db to database.yml
	sed -i -e "/default:/r $samples/postinstall/database.yml.db.txt" $root/config/database.yml
}

