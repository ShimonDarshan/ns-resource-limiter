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

.PHONY: cluster.image.delete
cluster.image.delete:
	minikube image rm $(FULL_DOCKER_IMAGE)

.PHONY: cluster.image.reload
cluster.image.reload: helm.uninstall cluster.image.delete cluster.image.load

HELM_RELEASE = "ns-resource-limiter"

# Helm deploy, use it for testing and development only.
.PHONY: helm.install
helm.install:
	helm upgrade --install \
		$(HELM_RELEASE) ./chart/ns-resource-limiter \
		-f renderd.values.yaml

.PHONY: helm.uninstall
helm.uninstall:
	helm uninstall $(HELM_RELEASE)

# Development helpers.
.PHONY: dev.cert.generate
dev.cert.generate:
	bash ./helpers/create_crt.sh