# pls sort alphabetically

default: dev

dev: dockers
	@echo "\033[34mCopying Dev configuration files\033[0m"

rebuild:
	docker stop $(docker ps -a -q)
	docker rm $(docker ps -a -q)
	docker builder prune --all --force
	docker-compose build

dockers:
	# prevent timeout
	export DOCKER_CLIENT_TIMEOUT=120
	export COMPOSE_HTTP_TIMEOUT=12
	docker-compose up --remove-orphans
	# fixed known api platform php-fpm issue
	docker-compose exec php php-fpm -D

