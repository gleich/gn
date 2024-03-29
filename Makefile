##########
# Building
##########

build-docker-prod:
	docker build .
build-docker-dev:
	docker build -f dev.Dockerfile .
build-docker-dev-lint:
	docker build -f dev.lint.Dockerfile .
build-go:
	go get -v -t -d ./...
	go build -v .
	rm gn

#########
# Linting
#########

lint-golangci:
	golangci-lint run
lint-gomod:
	go mod tidy
	git diff --exit-code go.mod
	git diff --exit-code go.sum
lint-goreleaser:
	goreleaser check
lint-hadolint:
	hadolint Dockerfile
	hadolint dev.Dockerfile
	hadolint dev.lint.Dockerfile
lint-in-docker:
	docker build -f dev.lint.Dockerfile -t mattgleich/gn:lint .
	docker run mattgleich/gn:lint

#########
# Testing
#########

test-go:
	go get -v -t -d ./...
	go test ./...
test-in-docker:
	docker build -f dev.Dockerfile -t mattgleich/gn:test .
	docker run mattgleich/gn:test

##########
# Grouping
##########

# Testing
local-test: test-go
docker-test: test-in-docker
# Linting
local-lint: lint-golangci lint-goreleaser lint-hadolint lint-gomod
docker-lint: lint-in-docker
# Build
local-build: build-docker-prod build-docker-dev build-docker-dev-lint
