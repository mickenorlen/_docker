#!/bin/sh
export $(egrep -v '^#' .env | xargs); # parse .env
source ./_docker/scripts.sh

# function startup() { # Commands run at container startup
# 	yarn install
# 	yarn webpack $1
# }

function help() { # Show list of functions
    grep "^function" "./_docker-resources/scripts/docker.sh" | cut -d ' ' -f2- | sed 's/{ //g'
		echo
    grep "^function" "./_docker/scripts.sh" | cut -d ' ' -f2- | sed 's/{ //g'
}

# Internal functions not listed in help as not prefixed by function
getEnv() {
	if [[ $1 == 'prod' ]]; then echo 'prod'; else echo 'dev'; fi
}

# Functions not listed in help as not prefixed by function
hasContainers() {
	[ $(sudo docker container ls -a -f "name=${APP_NAME}_$1" | wc -l) -gt 1 ]
}

hasImages() {
	[ $(sudo docker images -f reference=$BUILD_IMAGE | wc -l) -gt 1 ]
}

hasParentImage() {
	[ $(sudo docker images -f reference=$PARENT_IMAGE | wc -l) -gt 1 ]
}

isRunning() {
	[ $(sudo docker container ls -f "name=${APP_NAME}_$1" | wc -l) -gt 1 ]
}

function list() { # List containers and images
	sudo docker ps -a
	echo
	sudo docker images
}

function rmc() { # Rm containers, $arg1 = env
	env=$(getEnv $1)
	if hasContainers $env; then
		stop $env;
		echo -en "\n$(sudo docker container ls -a -f "name=${APP_NAME}_${env}*")\nRemove listed? y/N: ";
		read reply;
		if [[ $reply == "y" ]]; then
			sudo docker rm $(sudo docker container ls -a -f "name=${APP_NAME}_${env}*" --format {{.ID}});
		fi
	else
		echo "No ${APP_NAME}_$env containers";
	fi
}

function rmi() { # Rm image $arg1 = force
	if hasImages || hasParentImage; then
		sudo docker images -f "reference=$BUILD_IMAGE";
		if hasParentImage; then
			echo -e "\nParent image - produced on rebuild" && sudo docker images -f "reference=$PARENT_IMAGE";
		fi
			echo $a
		echo -n "Remove listed? y/N: ";

		read reply;
		if [[ $reply == 'y' ]]; then
			[[ $1 == 'force' ]] && force='-f' || force=''; # Set force or empty
			sudo docker rmi $(sudo docker images -f "reference=$BUILD_IMAGE" --format {{.ID}}) $force;
			if hasParentImage; then
				sudo docker rmi $(sudo docker images -f "reference=$PARENT_IMAGE" --format {{.ID}}) $force;
			fi
		fi
	else
		echo "No images"
	fi
}

function rmall() { # Rm: containers, images, deps, $arg1 = env
	env=$(getEnv $1)
	rmc $env
	echo
	rmi $env
	# yarn clean TODO
}

function rebuild() { # Rebuild image $BUILD_IMAGE from _docker (.env)
	sudo -E docker build --build-arg PARENT_IMAGE=$PARENT_IMAGE _docker -t $BUILD_IMAGE
}

function push() { # Push rebuilt image $BUILD_IMAGE to docker hub
	sudo docker login
	sudo docker push $BUILD_IMAGE
}

# Containers
function start() { # Start/restart container, $arg1 = env
	env=$(getEnv $1)
	echo "env: $env"
	export CURRENT_UID=$(id -u):$(id -g);
	stop $env;
	if [[ $env == 'prod' ]]; then
		sudo -E docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d;
	else
		sudo -E docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d;
	fi
}

function stop() { # Stop container, $arg1 = env
	env=$(getEnv $1)
	if isRunning $env; then
		echo "Stopping ${APP_NAME}_$env containers";
		sudo docker stop $(sudo docker container ls -af "name=${APP_NAME}_${env}*" --format {{.ID}});
	fi
}

function logs() { # Get container log, $arg1 = env
	env=$(getEnv $1)
	if hasContainers $env; then
		sudo docker logs -f $(sudo docker container ls -af "name=${APP_NAME}_${env}_web" --format {{.ID}});
	else
		echo "${APP_NAME}_${env}_web no container"
	fi
}

function clearlogs() { # Clear logs of container, arg1 = env
	env=$(getEnv $1)
	if hasContainers $env; then
		sudo truncate -s 0 $(sudo docker inspect --format='{{.LogPath}}' ${APP_NAME}_${env}_web)
	else
		echo "${APP_NAME}_${env}_web no container"
	fi
}

function bash() { # Enter container with bash, $arg1 = env
	env=$(getEnv $1)
	if isRunning $env; then
		sudo docker exec -it "${APP_NAME}_${env}_web" /bin/bash
	else
		echo "Not running"
	fi
}

function rootbash() { # Enter container as root with bash, $arg1 = env
	env=$(getEnv $1)
	if isRunning $env; then
		sudo docker exec --user 0 -it "${APP_NAME}_${env}_web" /bin/bash
	else
		echo "Not running"
	fi
}

