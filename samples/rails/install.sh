#!/bin/bash
# Run from postinit.sh
install() {
	data=$root/_docker/data
	mkdir -p $data/db $data/home $data/bundle

	# Soft copy samples
	$(./utils.sh cpSamples "$samples/root" "$root");
	$(./utils.sh cpSamples "$samples/docker" "$root/_docker");
	$(./utils.sh cpSamples "$samples/home" "$data/home");


	cd $root

	# Update .env
	echo -n "Edit .env: APP_NAME/BUILD_IMAGE [enter]"
	read waiting
	$($scripts/utils.sh getEnv "$root/.env")
	# Install rails
	export CURRENT_UID=$(id -u):$(id -g);
	echo -e "\nGetting $BUILD_IMAGE locally, pulling from hub or falling back to _docker/Dockerfile...\n"
	yarn d hasImages 2>/dev/null || sudo -E docker-compose pull web || yarn d rebuild
	sudo -E docker-compose run --no-deps --rm --user 0 web bash -c "chown $CURRENT_UID /home/docker"
	sudo -E docker-compose run --no-deps --rm web bash -c "bundle install && bundle exec rails new . --force -B --database=postgresql && bundle update"

	# Add to gitignore
	echo "
# Docker
_docker/data
!_docker/data/home
_docker/data/home/.bundle" >> $root/.gitignore

	# Insert scripts to package.json
	sed -i -e "/\"private\"/r $samples/postinstall/package.json.script.txt" $root/package.json
	# Insert db to database.yml
	sed -i -e "/default:/r $samples/postinstall/database.yml.db.txt" $root/config/database.yml
	sed -i "s/app_/${APP_NAME}_/g" $root/config/database.yml
	yarn d start
	sudo -E docker-compose run --no-deps --rm web bash -c "bundle exec rails db:create"

	echo -e "\nDone! Rails at http://localhost:3000"
}

