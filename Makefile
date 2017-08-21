SHELL = /bin/bash
#DOCKER_REPOSITORY := registry-gitlab.llach.pl/llach/satis-server
IMAGE_NAME ?= lukaszlach/satis-server
IMAGE_TAG ?= $(or ${CI_COMMIT_TAG}, latest)
VERSION ?= $(or ${CI_COMMIT_TAG}, dev-master)
BUILD_ID ?= -
WEBHOOK_VERSION ?= 2.6.5
TEST_HOSTNAME ?= localhost

.PHONY: man build push start stop restart run simple-run docker-compose-run cli

build: man
	docker build --force-rm --rm --compress --build-arg SATIS_SERVER_VERSION="$(VERSION) (build $(BUILD_ID))" --build-arg WEBHOOK_VERSION="$(WEBHOOK_VERSION)" -t $(IMAGE_NAME):$(IMAGE_TAG) .

man:
	docker run -v `pwd`:/source jagregory/pandoc -f markdown -t html README.md -o README.html
	sed '/^\[!\[/d; /^!\[/d' README.md > README.txt

push:
	#docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(DOCKER_REPOSITORY):$(IMAGE_TAG)
	#docker push $(DOCKER_REPOSITORY):$(IMAGE_TAG)
	docker push $(IMAGE_NAME):$(IMAGE_TAG)

start:
	docker run -d -p 9000:80 -v `pwd`/test/:/etc/satis/ -v `pwd`/var/:/var/satis-server/ --name satis_server $(IMAGE_NAME):$(IMAGE_TAG)
	docker ps

stop:
	docker stop satis_server || true
	docker rm satis_server || true

restart: stop start

run:
	if [ ! -d etc/ ]; then mkdir etc/; fi
	if [ ! -d var/ ]; then mkdir var/; fi
	docker run --rm -it -p 9000:80 -v `pwd`/test/:/etc/satis/ -v `pwd`/var/:/var/satis-server/ -v `pwd`/etc/:/etc/satis-server/ -v `pwd`/nginx/:/satis-server/nginx/ -e SATIS_REBUILD_AT="0 1 * * *" -e TZ="$$(date +%z | cut -c1 | tr + _ | tr - + | tr _ -)$$((`date +%z | cut -c3-5` / 100))" -e SSL_PORT=443 -e PUSH_SECRET=d5a7c0d0c897665588cd0844744e3109 -e API_ALLOW=0.0.0.0/0 --name satis_server $(IMAGE_NAME):$(IMAGE_TAG)

simple-run:
	docker run -d -p 9000:80 -v /etc/satis:/etc/satis/ -v /etc/satis-server/:/etc/satis-server/ -v /var/satis-server/:/var/satis-server/ --name satis_server $(IMAGE_NAME):$(IMAGE_TAG)

docker-compose-run:
	sed 's/latest/$(IMAGE_TAG)/g' docker-compose.yml.example > docker-compose.yml.example.1
	docker-compose -f docker-compose.yml.example.1 up -d

cli:
	docker exec -it satis_server sh

#
.PHONY: test
test: test-ping test-remove test-add test-build test-build-all test-list test-show test-version test-index test-help test-help-html test-composer

test-push:
	curl -v -d'{"repository":{"url":"https://github.com/php-amqplib/php-amqplib"}}' -H"Content-Type: application/json" "http://$(TEST_HOSTNAME):9000/api/push?secret=d5a7c0d0c897665588cd0844744e3109"

test-invalid-push:
	curl -v -d'{"repository":{"url":"https://github.com/lukaszlach/invalid"}}' -H"Content-Type: application/json" http://$(TEST_HOSTNAME):9000/api/push

test-add:
	curl -v -d'url=https://github.com/php-amqplib/php-amqplib' http://$(TEST_HOSTNAME):9000/api/add

test-show:
	curl -v -d'url=https://github.com/php-amqplib/php-amqplib' http://$(TEST_HOSTNAME):9000/api/show

test-remove:
	curl -v -d'url=https://github.com/php-amqplib/php-amqplib' http://$(TEST_HOSTNAME):9000/api/remove

test-build:
	curl -v -d'url=https://github.com/php-amqplib/php-amqplib' http://$(TEST_HOSTNAME):9000/api/build

test-build-all:
	curl -v http://$(TEST_HOSTNAME):9000/api/build-all

test-dump:
	curl -v http://$(TEST_HOSTNAME):9000/api/dump

test-list:
	curl -v http://$(TEST_HOSTNAME):9000/api/list

test-version:
	curl -v http://$(TEST_HOSTNAME):9000/api/version

test-index:
	curl -v http://$(TEST_HOSTNAME):9000/index.html | head -n 10

test-ping:
	curl -v http://$(TEST_HOSTNAME):9000/ping
	curl -v http://$(TEST_HOSTNAME):9000/api/ping

test-help-html:
	curl -vL http://$(TEST_HOSTNAME):9000/help | head -n 10

test-help:
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) help | head -n 10

test-composer:
	docker run --rm $(IMAGE_NAME):$(IMAGE_TAG) composer -n | head -n 10

test-sh:
	docker cp test/test.sh satis_server:/tmp
	docker exec satis_server sh /tmp/test.sh