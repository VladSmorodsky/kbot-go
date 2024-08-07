ifeq '$(findstring ;,$(PATH))' ';'
    DETECTED_OS := windows
	DETECTED_ARCH := amd64
else
    DETECTED_OS := $(shell uname | tr '[:upper:]' '[:lower:]' 2> /dev/null || echo Unknown)
    DETECTED_OS := $(patsubst CYGWIN%,Cygwin,$(DETECTED_OS))
    DETECTED_OS := $(patsubst MSYS%,MSYS,$(DETECTED_OS))
    DETECTED_OS := $(patsubst MINGW%,MSYS,$(DETECTED_OS))
	DETECTED_ARCH := $(shell dpkg --print-architecture 2>/dev/null || amd64)
endif

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
	docker build . -t ${REGISTRY}/${APP_NAME}:${VERSION}-${TARGET_ARCH} --build-arg TARGET_OS=${TARGET_OS} --build-arg TARGET_ARCH=${TARGET_ARCH}


push:
	docker push ${REGISTRY}/${APP_NAME}:${VERSION}-${TARGET_ARCH}

linux: format get
	CGO_ENABLED=0 GOOS=linux GOARCH=$(DETECTED_ARCH) go build -v -o kbot-go -ldflags "-X="github.com/VladSmorodsky/kbot-go/cmd.appVersion=${VERSION}
	docker build --build-arg TARGET_OS=linux --build-arg TARGET_ARCH=${DETECTED_ARCH} -t ${REGISTRY}/${APP_NAME}:${VERSION}-$(DETECTED_ARCH) .

windows: format get
	CGO_ENABLED=0 GOOS=windows GOARCH=$(DETECTED_ARCH) go build -v -o kbot-go -ldflags "-X="github.com/VladSmorodsky/kbot-go/cmd.appVersion=${VERSION}
	docker build --build-arg TARGET_OS=windows --build-arg TARGET_ARCH=amd64 -t ${REGISTRY}/${APP_NAME}:${VERSION}-$(DETECTED_ARCH) .

darwin: format get
	CGO_ENABLED=0 GOOS=darwin GOARCH=$(DETECTED_ARCH) go build -v -o kbot-go -ldflags "-X="github.com/VladSmorodsky/kbot-go/cmd.appVersion=${VERSION}
	docker build --build-arg TARGET_OS=darwin -t ${REGISTRY}/${APP_NAME}:${VERSION}-$(DETECTED_ARCH) .

arm: format get
	CGO_ENABLED=0 GOOS=$(DETECTED_OS) GOARCH=arm go build -v -o kbot-go -ldflags "-X="github.com/VladSmorodsky/kbot-go/cmd.appVersion=${VERSION}
	docker build --build-arg TARGET_OS=arm -t ${REGISTRY}/${APP_NAME}:${VERSION}-arm .

clean:
	@rm -rf kbot; \
	IMG1=$$(docker images -q | head -n 1); \
	if [ -n "$${IMG1}" ]; then  docker rmi -f $${IMG1}; else printf "$RImage not found$D\n"; fi