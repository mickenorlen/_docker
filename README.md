# Setup
```
mkdir app && cd app
git submodule add git@github.com:mickenorlen/_docker-resources.git
./_docker-resources/scripts/init.sh rails
yarn d start

# Edit db names in yaml
yarn d bash
rails db:create
```

Navigate to:
- <localhost:3000> # app
- <localhost:8080> # adminer
