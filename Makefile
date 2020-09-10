# pls sort alphabetically

default: dev

dev: dockers
	@echo "\033[34mCopying Dev configuration files\033[0m"

rebuild:
	docker ps -a -q | xargs -n 1 -P 8 -I {} docker stop {}
	docker builder prune --all --force
	docker-compose build

dockers:
	# prevent timeout
	export DOCKER_CLIENT_TIMEOUT=120
	export COMPOSE_HTTP_TIMEOUT=12
	docker-compose up --remove-orphans
	# fixed known api platform php-fpm issue
	docker-compose exec php php-fpm -D


# Setup ————————————————————————————————————————————————————————————————————————
SHELL         = bash
PROJECT       = strangebuzz
EXEC_PHP      = php
REDIS         = redis-cli
GIT           = git
GIT_AUTHOR    = COil
SYMFONY       = docker-compose exec $(EXEC_PHP) bin/console
SYMFONY_BIN   = symfony
COMPOSER      = $(EXEC_PHP) composer.phar
DOCKER        = docker
DOCKER_COMP   = docker-compose
BREW          = brew
.DEFAULT_GOAL = help
#.PHONY       = # Not needed for now

## —— 🐝 The Strangebuzz Symfony Makefile 🐝 ———————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

wait: ## Sleep 5 seconds
	sleep 5

## —— Composer 🧙‍♂️ ————————————————————————————————————————————————————————————
install: composer.lock ## Install vendors according to the current composer.lock file
	$(COMPOSER) install --no-progress --no-suggest --prefer-dist --optimize-autoloader

update: composer.json ## Update vendors according to the composer.json file
	$(COMPOSER) update

## —— Symfony 🎵 ———————————————————————————————————————————————————————————————
sf: ## List all Symfony commands
	$(SYMFONY)

cc: ## Clear the cache. DID YOU CLEAR YOUR CACHE????
	$(SYMFONY) c:c

warmup: ## Warmup the cache
	$(SYMFONY) cache:warmup

fix-perms: ## Fix permissions of all var files
	chmod -R 777 var/*

assets: purge ## Install the assets with symlinks in the public folder
	$(SYMFONY) assets:install public/ --symlink --relative

purge: ## Purge cache and logs
	rm -rf var/cache/* var/logs/*

## —— Symfony binary 💻 ————————————————————————————————————————————————————————
bin-install: ## Download and install the binary in the project (file is ignored)
	curl -sS https://get.symfony.com/cli/installer | bash
	mv ~/.symfony/bin/symfony .

cert-install: ## Install the local HTTPS certificates
	$(SYMFONY_BIN) server:ca:install

serve: ## Serve the application with HTTPS support
	$(SYMFONY_BIN) serve --daemon --port=8000

unserve: ## Stop the webserver
	$(SYMFONY_BIN) server:stop

# Snippet L70+12 => templates/blog/posts/_64.html.twig

## —— Docker 🐳 ————————————————————————————————————————————————————————————————
up: docker-compose.yaml ## Start the docker hub (MySQL,redis,adminer,elasticsearch,head,Kibana)
	$(DOCKER_COMP) -f docker-compose.yaml up -d

docker-build: docker-compose.yaml ## UP+rebuild the application image
	$(DOCKER_COMP) -f docker-compose.yaml up -d --build

down: docker-compose.yaml ## Stop the docker hub
	$(DOCKER_COMP) down --remove-orphans

dpsn: ## List Docker containers for the project
	$(DOCKER_COMP) images
	@echo "--------------------------------------------------------------------------------------------------------------"
	docker ps -a | grep "sb-"
	@echo "--------------------------------------------------------------------------------------------------------------"

wait-for-mysql: ## Wait for MySQL to be ready
	bin/wait-for-mysql.sh

wait-for-elasticsearch: ## Wait for Elasticsearch to be ready
	bin/wait-for-elasticsearch.sh

bash: ## Connect to the application container
	$(DOCKER) container exec -it sb-app bash

	## —— Project 🐝 ———————————————————————————————————————————————————————————————
run: up wait-for-mysql load-fixtures wait-for-elasticsearch populate serve ## Start docker, load fixtures, populate the Elasticsearch index and start the webserver

reload: load-fixtures populate ## Reload fixtures and repopulate the Elasticserch index

abort: down unserve ## Stop docker and the Symfony binary server

cc-redis: ## Flush all Redis cache
	$(REDIS) -p 6389 flushall

commands: ## Display all commands in the project namespace
	$(SYMFONY) list $(PROJECT)

load-fixtures: ## Build the DB, control the schema validity, load fixtures and check the migration status
	$(SYMFONY) doctrine:cache:clear-metadata
	$(SYMFONY) doctrine:database:create --if-not-exists
	$(SYMFONY) doctrine:schema:drop --force
	$(SYMFONY) doctrine:schema:create
	$(SYMFONY) doctrine:schema:validate
	$(SYMFONY) doctrine:fixtures:load -n

init-snippet: ## Initialize a new snippet
	$(SYMFONY) $(PROJECT):init-snippet


## —— Tests ✅ —————————————————————————————————————————————————————————————————
test: phpunit.xml ## Launch main functional and unit tests
	./vendor/bin/phpunit --testsuite=main --stop-on-failure

test-external: phpunit.xml ## Launch tests implying external resources (API, services...)
	./vendor/bin/phpunit --testsuite=external --stop-on-failure

test-all: phpunit.xml ## Launch all tests
	./vendor/bin/phpunit --stop-on-failure

## —— Coding standards ✨ ——————————————————————————————————————————————————————
cs: codesniffer stan lint ## Launch check style and static analysis

codesniffer: ## Run php_codesniffer only
	./vendor/squizlabs/php_codesniffer/bin/phpcs --standard=phpcs.xml -n -p src/

stan: ## Run PHPStan only
	./vendor/bin/phpstan analyse -l max --memory-limit 1G -c phpstan.neon src/

psalm: ## Run psalm only
	./vendor/bin/psalm --show-info=false

init-psalm: ## Init a new psalm config file for a given level, it must be decremented to have stricter rules
	rm ./psalm.xml
	./vendor/bin/psalm --init src/ 3

cs-fix: ## Run php-cs-fixer and fix the code.
	./vendor/bin/php-cs-fixer fix src/

## —— Deploy & Prod 🚀 —————————————————————————————————————————————————————————
deploy: ## Full no-downtime deployment with EasyDeploy
	$(SYMFONY) deploy -v

env-check: ## Check the main ENV variables of the project
	printenv | grep -i app_

le-renew: ## Renew Let's Encrypt HTTPS certificates
	certbot --apache -d strangebuzz.com -d www.strangebuzz.com

## —— Yarn 🐱 / JavaScript —————————————————————————————————————————————————————
devjs: ## Rebuild assets for the dev env
	yarn install
	yarn run encore dev

watch: ## Watch files and build assets when needed for the dev env
	yarn run encore dev --watch

build: ## Build assets for production
	yarn run encore production

lint: ## Lints Js files
	npx eslint assets/js --fix

## —— Stats 📜 —————————————————————————————————————————————————————————————————
stats: ## Commits by the hour for the main author of this project
	$(GIT) log --author="$(GIT_AUTHOR)" --date=iso | perl -nalE 'if (/^Date:\s+[\d-]{10}\s(\d{2})/) { say $$1+0 }' | sort | uniq -c|perl -MList::Util=max -nalE '$$h{$$F[1]} = $$F[0]; }{ $$m = max values %h; foreach (0..23) { $$h{$$_} = 0 if not exists $$h{$$_} } foreach (sort {$$a <=> $$b } keys %h) { say sprintf "%02d - %4d %s", $$_, $$h{$$_}, "*"x ($$h{$$_} / $$m * 50); }'