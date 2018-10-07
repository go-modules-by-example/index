#!/usr/bin/env bash

# **START**

export GOPATH=$HOME
export PATH=$GOPATH/bin:$PATH
echo "machine github.com login $GITHUB_USERNAME password $GITHUB_PAT" >> $HOME/.netrc
echo "" >> $HOME/.netrc
echo "machine api.github.com login $GITHUB_USERNAME password $GITHUB_PAT" >> $HOME/.netrc
git config --global user.email "$GITHUB_USERNAME@example.com"
git config --global user.name "$GITHUB_USERNAME"
git config --global advice.detachedHead false

# block: setup
mkdir hello
cd hello
go mod init example.com/hello

cat <<EOD > hello.go
package main

import (
	"fmt"
	"rsc.io/quote"
)

func main() {
   fmt.Println(quote.Hello())
}
EOD
gofmt -w hello.go

# block: example
cat hello.go

# block: run
go run .

# block: go mod download
go mod download

# block: fake vendor
rm -rf modvendor
tgp=$(mktemp -d)
GOPROXY=file://$GOPATH/pkg/mod/cache/download GOPATH=$tgp go mod download
cp -rp $GOPATH/pkg/mod/cache/download/ modvendor
GOPATH=$tgp go clean -modcache
rm -rf $tgp

# block: review modvendor
find modvendor -type f

# block: check modvendor
GOPATH=$(mktemp -d) GOPROXY=file://$PWD/modvendor go run .

# block: version details
go version
