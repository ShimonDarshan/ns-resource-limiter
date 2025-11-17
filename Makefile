DOCKER_REPO = devopsrepos
DOCKER_IMAGE = ns-resource-limiter
DOCKER_TAG = stable
FULL_DOCKER_IMAGE = $(DOCKER_REPO)/$(DOCKER_IMAGE):$(DOCKER_TAG)

BINARY_FOLDER = "./bin"
BINARY_NAME = "ns-resource-limiter"


.PHONY: build
build:
	CGO_ENABLED=0 GOOS=linux go build -o $(BINARY_FOLDER)/$(BINARY_NAME) main.go

.PHONY: docker.build
docker.build: build
	docker build --no-cache . -f Dockerfile -t $(FULL_DOCKER_IMAGE)


.PHONY: cluster.create
cluster.create:
	minikube start

.PHONY: cluster.destroy
cluster.destroy:
	minikube delete

.PHONY: cluster.restart
cluster.restart:
	minikube stop; minikube start

.PHONY: cluster.recreate
cluster.recreate: cluster.destroy cluster.create


.PHONY: cluster.image.load
cluster.image.load:
	minikube image load $(FULL_DOCKER_IMAGE)


HELM_RELEASE = "ns-resource-limiter"

.PHONY: helm.install
helm.install:
	helm upgrade --install $(HELM_RELEASE) ./chart/ns-resource-limiter

.PHONY: helm.uninstall
helm.uninstall:
	helm uninstall $(HELM_RELEASE)