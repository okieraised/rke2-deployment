TAG := 3.0.6-sso
DOCKER_IMAGE := registry.homelab.io/custom/airflow:${TAG}

PHONY: .build .push

build:
	docker build -t${DOCKER_IMAGE} .

push:
	docker push ${DOCKER_IMAGE}