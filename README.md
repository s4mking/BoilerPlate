**Long Story Short:**

This is a repository `api-platform-mysql8` done by me: Andy Ng (andy@pcinvent.com), CEO of AITRADE, INC. (www.aitrade.ai)
My Profile: https://www.linkedin.com/in/pcinvent/

[API Platform](https://github.com/api-platform/api-platform "API Platform") that comes with the latest best enterprise PHP Framework [Symfony](https://github.com/symfony/symfony "Symfony"), [React-Admin](https://github.com/marmelab/react-admin "React-Admin") Dashboard, [GraphQL](https://graphql.org/ "GraphQL"), etc. which are all great,


------------

> #### However, API Platform is by default built with PostgreSQL. To make API Platoform project work for MySQL 8.  I am here to share this and hope all can fork and contribute this open source project to save you time of scratching head.

------------


#### Features

- Made doctrine to work with MySQL 8
- Changed Docker-Compose images to 8
- Fixed the failure of php docker-entrypoint.sh to allow auto migration
- Changed .gitignore for common IDE/Editor and Mysql Docker
- Created Makefile script to run this docker-compose heathly (Please check the following explanation)

#### makefile
You can run this `make` which is just a wrapper of some commands that will resolve your docker-compose up issues.
If you encounter any docker issue, run `make rebuild`, then `make`.
If you do not want to install make binary, you can just run whatever the following commands listed below:

`make rebuild`
pruning all of your docker images and instances if you encounter mysql image with different tag issues. For example, you were using Mysql 5, then now using the Mysql 8 docker, you should see a lot problem in term of upgrading, so here you go:
```shell
	docker stop $(docker ps -a -q)
	docker rm $(docker ps -a -q)
	docker builder prune --all --force
	docker-compose build
```

`make`
Preventing timeout when you are first running this dokcer-compose, and fixed the problem of `php-fpm` have to restart due to the API-Platform with MySQL issue.
```shell
	# prevent timeout
	export DOCKER_CLIENT_TIMEOUT=120
	export COMPOSE_HTTP_TIMEOUT=12
	docker-compose up --remove-orphans
	# fixed known api platform php-fpm issue
	docker-compose exec php php-fpm -D
```

