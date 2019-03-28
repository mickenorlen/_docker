
# Data
function fetchdropboxdb() { # Fetch dropbox sql backup
	wget -O ${DB_PATH}/${APP_NAME}_db.sql.gz $DROPBOX_SQL_LINK
	gzip -df ${DB_PATH}/${APP_NAME}_db.sql.gz

}

function fetchsrvdb() { # fetch db from srv
	ssh -t ${SRV_USER}@${SRV_DOMAIN} "sudo docker exec -it ${APP_NAME}_prod_web /typo3_db/packdb.sh" &&
	rsync -chavzP --stats ${SRV_USER}@${SRV_DOMAIN}:${SRV_REPO_PATH}/vendor/sharetransition/typo3_db/typo3_db.sql ./vendor/sharetransition/typo3_db/typo3_db.sql;
}

function fetchfileadmin() {
	rsync -chavzP --stats ${SRV_USER}@${SRV_DOMAIN}:${SRV_REPO_PATH}/web/fileadmin ./web --delete
}

function fetchstate() { # Sync package states
	rsync -chavzP --stats ${SRV_USER}@${SRV_DOMAIN}:${SRV_REPO_PATH}/web/typo3conf/PackageStates.php ./web/typo3conf
	rsync -chavzP --stats ${SRV_USER}@${SRV_DOMAIN}:${SRV_REPO_PATH}/web/typo3conf/realurl_conf.php ./web/typo3conf
	rm -rf ./web/typo3temp
}

function setupdb() { # Run setupdb script
	if [[ $1 == 'prod' ]]; then
		sudo docker exec -it ${APP_NAME}_prod_web /typo3_db/setupdb.sh
	else
		sudo docker exec -it ${APP_NAME}_dev_web /typo3_db/setupdb.sh
	fi
}

function syncfromsrv() { # Sync all settings from srv, $arg1 = livedb, if packing db directly from live
	echo "Fetching db";
	if [[ $1 == 'livedb' ]]; then
		fetchsrvdb
	else
		fetchdropboxdb
	fi

	if [ $? -ne 0 ]; then
		echo 'Could not fetch db'
	else
		echo "Setting up locally" &&
		echo &&
		setupdb &&
		echo "Fetching fileadmin" &&
		echo &&
		fetchfileadmin &&
		echo "Fetching state" &&
		fetchstate &&
		echo &&
		echo "Now you just have to create a localhost domain entry!"
	fi
}

