#!/bin/sh
utils='./_docker-resources/scripts/utils.sh'
$($utils "parseEnv" ".env")
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
	if [[ $1 == 'prod' ]]; then echo 'prod'; elif [[ $1 == 'staging' ]]; then echo 'staging'; elif [[ $1 == 'idle' ]]; then echo 'idle'; else echo 'dev'; fi
}

getService() {
	if [[ -z $1 ]]; then echo 'web'; else echo $1; fi
}

composeCommand() {
	if [[ $1 == 'prod' ]]; then
		echo 'docker-compose -f docker-compose.yml -f docker-compose.prod.yml';
	elif [[ $1 == 'staging' ]]; then
		echo 'docker-compose -f docker-compose.yml -f docker-compose.staging.yml';
	elif [[ $1 == 'idle' ]]; then
		echo 'docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.idle.yml';
	else
		echo 'docker-compose -f docker-compose.yml -f docker-compose.dev.yml';
	fi
}

# Functions not listed in help as not prefixed by function
hasContainers() {
	[ $(docker container ls -a -f "name=${APP_NAME}_$1" | wc -l) -gt 1 ]
}

hasImages() {
	[ $(docker images -f reference=$BUILD_IMAGE | wc -l) -gt 1 ]
}

hasParentImage() {
	[ $(docker images -f reference=$PARENT_IMAGE | wc -l) -gt 1 ]
}

isRunning() {
	[ $(docker container ls -f "name=${APP_NAME}_$1" | wc -l) -gt 1 ]
}

function list() { # List containers and images
	docker ps -a
	echo
	docker images
}

function df() { # Get docker disk usage
	docker system df
}

function pruneall() { # Prune all stopped and unused including volumes, $arg1 = force
	[[ $1 == 'force' ]] && force='-f' || force=''; # Set force or empty
	docker system prune --all --volumes $force;
}

function rmc() { # Rm containers, $arg1 = env
	env=$(getEnv $1)
	if hasContainers $env; then
		stop $env;
		echo -en "\n$(docker container ls -a -f "name=${APP_NAME}_${env}*")\nRemove listed? y/N: ";
		read reply;
		if [[ $reply == "y" ]]; then
			docker rm $(docker container ls -a -f "name=${APP_NAME}_${env}*" --format {{.ID}});
		fi
	else
		echo "No ${APP_NAME}_$env containers";
	fi
}

function rmi() { # Rm image $arg1 = force
	if hasImages || hasParentImage; then
		docker images -f "reference=$BUILD_IMAGE";
		if hasParentImage; then
			echo -e "\nParent image - produced on rebuild" && docker images -f "reference=$PARENT_IMAGE";
		fi
			echo $a
		echo -n "Remove listed? y/N: ";

		read reply;
		if [[ $reply == 'y' ]]; then
			[[ $1 == 'force' ]] && force='-f' || force=''; # Set force or empty
			docker rmi $(docker images -f "reference=$BUILD_IMAGE" --format {{.ID}}) $force;
			if hasParentImage; then
				docker rmi $(docker images -f "reference=$PARENT_IMAGE" --format {{.ID}}) $force;
			fi
		fi
	else
		echo "No images"
	fi
}

function rmci() { # Rm: containers, images, deps, $arg1 = env
	env=$(getEnv $1)
	rmc $env
	echo
	rmi $env
	# yarn clean TODO
}

function rebuild() { # Rebuild image $BUILD_IMAGE from _docker (.env)
	docker build --build-arg PARENT_IMAGE=$PARENT_IMAGE _docker -t $BUILD_IMAGE
}

function pull() { # $arg1 = env
	export CURRENT_UID=$(id -u):$(id -g);
	$(composeCommand $1) pull
}

function push() { # Push rebuilt image $BUILD_IMAGE to docker hub
	docker login
	docker push $BUILD_IMAGE
}

# Containers
function start() { # Start/restart container, $arg1 = env
	export CURRENT_UID=$(id -u):$(id -g);
	env=$(getEnv $1)
	echo "env: $env"
	stop $env;
	$(composeCommand $1) up -d
}

function stop() { # Stop container, $arg1 = env
	env=$(getEnv $1)
	if isRunning $env; then
		echo "Stopping ${APP_NAME}_$env containers";
		docker stop $(docker container ls -af "name=${APP_NAME}_${env}*" --format {{.ID}});
	fi
}

function logs() { # Get container log, $arg1 = env, $arg2 = service, $arg3 = follow=true, $arg4 = lines=100
	env=$(getEnv $1)
	service=$(getService $2)
	[[ $3 == 'false' ]] && follow='' || follow='-f'; # Set force or empty
	[[ -z $4 ]] && lines='100' || lines=$4; # Set force or empty
	if hasContainers $env; then
		docker logs ${follow} $(docker container ls -af "name=${APP_NAME}_${env}_${service}" --format {{.ID}}) --tail	$lines;
	else
		echo "${APP_NAME}_${env}_${service} no container"
	fi
}

function clearlogs() { # Clear logs of container, $arg1 = env, $arg2 = service
	env=$(getEnv $1)
	service=$(getService $2)
	if hasContainers $env; then
		sudo truncate -s 0 $(docker inspect --format='{{.LogPath}}' ${APP_NAME}_${env}_${service})
	else
		echo "${APP_NAME}_${env}_${service} no container"
	fi
}

function bash() { # Enter container with bash, $arg1 = env, $arg2 = service
	env=$(getEnv $1)
	service=$(getService $2)
	if isRunning $env; then
		docker exec -it "${APP_NAME}_${env}_${service}" /bin/bash
	else
		echo "Not running"
	fi
}

function rootbash() { # Enter container as root with bash, $arg1 = env $arg2 = service
	env=$(getEnv $1)
	service=$(getService $2)
	if isRunning $env; then
		docker exec --user 0 -it "${APP_NAME}_${env}_${service}" /bin/bash
	else
		echo "Not running"
	fi
}

function exec() { # Exec in container, $arg1 = env, $arg2 = service, $arg3 = command
	export CURRENT_UID=$(id -u):$(id -g);
	cmd=$(composeCommand $1)
	service=$(getService $2)
	$cmd run --no-deps --rm ${service} bash -c "${3}"
}

function mountremote() { # Mount remote to _remote
	sshfs ${SRV_USER}@${SRV_DOMAIN}:${SRV_REPO_PATH} _remote
}

function umountremote() { # Unmount _remote
	# fusermount -u _remote
	sudo umount -l _remote
}


