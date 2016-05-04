PROJECT=ping-pong-grpc
ORGANIZATION=denderello

BUILD_PATH := $(shell pwd)/build
PROJECT_PATH := "github.com/$(ORGANIZATION)/$(PROJECT)"

GOVERSION=1.6

BIN := $(PROJECT)

VERSION := $(shell cat VERSION)
COMMIT := $(shell git rev-parse --short HEAD)

.PHONY: all clean 

SOURCE=$(shell find . -name '*.go')

ifndef GOOS
	GOOS := linux
endif
ifndef GOARCH
	GOARCH := amd64
endif

all: $(BIN)

clean:
	rm -rf $(BUILD_PATH)

build:
	mkdir -p $(BUILD_PATH)

$(BIN): $(SOURCE) VERSION build
	@echo Building in Docker container for $(GOOS)/$(GOARCH)
	docker run \
			--rm \
			-v $(shell pwd):/go/src/$(PROJECT_PATH) \
			-e GOOS=$(GOOS) \
			-e GOARCH=$(GOARCH) \
			-w /go/src/$(PROJECT_PATH) \
			golang:$(GOVERSION) \
			go build -o build/$(BIN) .

protoc:
	protoc -I protos protos/helloworld.proto --go_out=plugins=grpc:helloworld