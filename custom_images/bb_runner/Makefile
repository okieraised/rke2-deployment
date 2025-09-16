TAG := homelab
DOCKER_IMAGE := registry.homelab.io/custom/bitbucket-runner:${TAG}

PHONY: .build .push

build:
	docker build -t${DOCKER_IMAGE} .

push:
	docker push ${DOCKER_IMAGE}