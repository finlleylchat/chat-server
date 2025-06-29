# Variables
LOCAL_BIN:=$(CURDIR)/bin
APP_NAME:=app
VERSION?=$(shell git describe --tags --always --dirty)
BUILD_TIME:=$(shell date -u '+%Y-%m-%d_%H:%M:%S')
LDFLAGS:=-ldflags "-X main.Version=$(VERSION) -X main.BuildTime=$(BUILD_TIME) -w -s"

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
BINARY_NAME=$(APP_NAME)
BINARY_UNIX=$(BINARY_NAME)_unix

# Default target
.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: install-deps
install-deps: ## Install development dependencies
	@echo "Installing development dependencies..."
	GOBIN=$(LOCAL_BIN) go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.61.0
	GOBIN=$(LOCAL_BIN) go install github.com/axw/gocov/gocov@latest
	GOBIN=$(LOCAL_BIN) go install github.com/AlekSi/gocov-xml@latest
	GOBIN=$(LOCAL_BIN) go install github.com/onsi/ginkgo/v2/ginkgo@latest
	GOBIN=$(LOCAL_BIN) go install github.com/securecodewarrior/gosec/v2/cmd/gosec@latest

.PHONY: build
build: ## Build the application
	@echo "Building $(BINARY_NAME)..."
	CGO_ENABLED=0 $(GOBUILD) $(LDFLAGS) -o $(LOCAL_BIN)/$(BINARY_NAME) ./cmd/main.go

.PHONY: build-all
build-all: ## Build for all platforms
	@echo "Building for all platforms..."
	GOOS=linux GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(LOCAL_BIN)/$(BINARY_NAME)-linux-amd64 ./cmd/main.go
	GOOS=linux GOARCH=arm64 $(GOBUILD) $(LDFLAGS) -o $(LOCAL_BIN)/$(BINARY_NAME)-linux-arm64 ./cmd/main.go
	GOOS=darwin GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(LOCAL_BIN)/$(BINARY_NAME)-darwin-amd64 ./cmd/main.go
	GOOS=darwin GOARCH=arm64 $(GOBUILD) $(LDFLAGS) -o $(LOCAL_BIN)/$(BINARY_NAME)-darwin-arm64 ./cmd/main.go
	GOOS=windows GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(LOCAL_BIN)/$(BINARY_NAME)-windows-amd64.exe ./cmd/main.go

.PHONY: test
test: ## Run tests
	@echo "Running tests..."
	$(GOTEST) -v -race -coverprofile=coverage.out ./...

.PHONY: test-coverage
test-coverage: ## Run tests with coverage report
	@echo "Running tests with coverage..."
	$(GOTEST) -v -race -coverprofile=coverage.out -covermode=atomic ./...
	$(LOCAL_BIN)/gocov test ./... | $(LOCAL_BIN)/gocov-xml > coverage.xml

.PHONY: test-benchmark
test-benchmark: ## Run benchmark tests
	@echo "Running benchmark tests..."
	$(GOTEST) -bench=. -benchmem ./...

.PHONY: lint
lint: ## Run linter
	@echo "Running linter..."
	$(LOCAL_BIN)/golangci-lint run ./... --config .golangci.pipeline.yaml

.PHONY: lint-fix
lint-fix: ## Run linter with auto-fix
	@echo "Running linter with auto-fix..."
	$(LOCAL_BIN)/golangci-lint run --fix ./... --config .golangci.pipeline.yaml

.PHONY: security
security: ## Run security scan
	@echo "Running security scan..."
	$(LOCAL_BIN)/gosec ./...

.PHONY: clean
clean: ## Clean build artifacts
	@echo "Cleaning..."
	$(GOCLEAN)
	rm -rf $(LOCAL_BIN)
	rm -f coverage.out coverage.xml

.PHONY: deps
deps: ## Download dependencies
	@echo "Downloading dependencies..."
	$(GOMOD) download
	$(GOMOD) tidy

.PHONY: deps-update
deps-update: ## Update dependencies
	@echo "Updating dependencies..."
	$(GOMOD) get -u ./...
	$(GOMOD) tidy

.PHONY: deps-check
deps-check: ## Check for outdated dependencies
	@echo "Checking for outdated dependencies..."
	$(GOMOD) list -u -m all

.PHONY: run
run: build ## Build and run the application
	@echo "Running $(BINARY_NAME)..."
	$(LOCAL_BIN)/$(BINARY_NAME)

.PHONY: docker-build
docker-build: ## Build Docker image
	@echo "Building Docker image..."
	docker build -t $(APP_NAME):$(VERSION) .
	docker tag $(APP_NAME):$(VERSION) $(APP_NAME):latest

.PHONY: docker-run
docker-run: docker-build ## Build and run Docker container
	@echo "Running Docker container..."
	docker run --rm -p 8080:8080 $(APP_NAME):$(VERSION)

.PHONY: docker-push
docker-push: docker-build ## Build and push Docker image
	@echo "Pushing Docker image..."
	docker push $(APP_NAME):$(VERSION)
	docker push $(APP_NAME):latest

.PHONY: ci
ci: deps lint test security ## Run CI pipeline locally
	@echo "CI pipeline completed successfully"

.PHONY: dev
dev: ## Development setup
	@echo "Setting up development environment..."
	make install-deps
	make deps
	make lint

.PHONY: release
release: clean deps lint test security build-all ## Prepare release
	@echo "Release $(VERSION) prepared successfully"