# babelBin="node_modules/babel-cli/bin/babel-node.js"
# webpackBin="node_modules/webpack/bin/webpack.js";


# if [ ! -d "./node_modules" ] || [ -z "$(ls ./node_modules)" ];
# 	then yarn install;
# else
# 	npm rebuild node-sass # Make sure correct env binary
# fi

echo "starting env: $APP_ENV"

# if [[ $APP_ENV == 'production' ]]; then
# 	mix phx.server
# 	# NODE_ENV=production $babelBin $webpackBin --mode production --config webpack.config.js &
# 	# NODE_ENV=production $babelBin app.js

# else #Development
# 	mix phx.server
# 	# NODE_ENV=development $babelBin $webpackBin --mode development --config webpack.config.js --watch &
# 	# NODE_ENV=development $babelBin app.js
# fi

# Wait until Postgres is ready
# while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER
# do
#   echo "$(date) - waiting for database to start"
#   sleep 2
# done

# # Create, migrate, and seed database if it doesn't exist.
# if [[ -z `psql -Atqc "\\list $PGDATABASE"` ]]; then
#   echo "Database $PGDATABASE does not exist. Creating..."
#   createdb -E UTF8 $PGDATABASE -l en_US.UTF-8 -T template0
#   mix ecto.migrate
#   mix run priv/repo/seeds.exs
#   echo "Database $PGDATABASE created."
# fi


mix phx.server

tail -f /dev/null # Keep running for debugging
