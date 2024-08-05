VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGET_OS=linux

format:
	gofmt -s -w ./

get:
	go get

lint:
	golint

test:
	go test -v


build: format get 
	CGO_ENABLED=0 COOS=${TARGET_OS} GOARCH=${shell dpkg --print-architecture} go build -v -o kbot-go -ldflags "-X="github.com/VladSmorodsky/kbot-go/cmd.appVersion=${VERSION}

clean:
	rm -rf kbot-go