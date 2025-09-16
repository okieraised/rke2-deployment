REGISTRY ?= registry.homelab.io/mlops
IMAGE_NAME ?= mlflow-oidc-auth
TAG ?= latest

# Full image reference
IMAGE := $(REGISTRY)/$(IMAGE_NAME):$(TAG)

.PHONY: build push

## Build the Docker image
build:
	docker build -t $(IMAGE) .

## Push the Docker image to the registry
push: build
	docker push $(IMAGE)
