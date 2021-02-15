APP_NAME := rails-vue-influxdb-example
IMAGE_NAME := rails-vue-influxdb-example
IMAGE_TAG := latest
RUBY_VERSION := $(shell cat .ruby-version)

.PHONY: network build server

network:
	docker network create rails_vue_influxdb_example-network

build:
	DOCKER_BUILDKIT=1 docker build \
		--build-arg APP_NAME=${APP_NAME} \
		--build-arg RUBY_VERSION=${RUBY_VERSION} \
		-t ${IMAGE_NAME}:${IMAGE_TAG} \
		.

server:
	@docker-compose up -d
	@docker container run --rm \
	--net=rails_vue_influxdb_example-network \
	--name ${APP_NAME} \
	-p 3000:3000 \
	-v ${PWD}:/home/app/${APP_NAME} \
	-v /home/app/${APP_NAME}/vendor/bundle \
	-v /home/app/${APP_NAME}/node_modules \
	${IMAGE_NAME}:${IMAGE_TAG}
