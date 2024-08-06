APP_NAME=$(shell basename `git rev-parse --show-toplevel`)
REGISTRY=vsmorodskyi
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGET_OS=linux
TARGET_ARCH=arm64

format:
	gofmt -s -w ./

get:
	go get

lint:
	golint

test:
	go test -v


build: format get 
	CGO_ENABLED=0 COOS=${TARGET_OS} GOARCH=${TARGET_ARCH} go build -v -o kbot-go -ldflags "-X="github.com/VladSmorodsky/kbot-go/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP_NAME}:${VERSION}-${TARGET_ARCH}

push:
	docker push ${REGISTRY}/${APP_NAME}:${VERSION}-${TARGET_ARCH}

clean:
	rm -rf kbot-go