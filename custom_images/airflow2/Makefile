TAG := 2.10.5-sso
DOCKER_IMAGE := registry.homelab.io/custom/airflow:${TAG}

PHONY: .build .push

build:
	docker build -t${DOCKER_IMAGE} .

push:
	docker push ${DOCKER_IMAGE}