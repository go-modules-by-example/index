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

# tidy up if we already have the repo
now=$(date +'%Y%m%d%H%M%S_%N')
githubcli repo renameIfExists $GITHUB_ORG/modvendor_example modvendor_example_$now
githubcli repo transfer $GITHUB_ORG/modvendor_example_$now $GITHUB_ORG_ARCHIVE
githubcli repo create $GITHUB_ORG/modvendor_example

# block: module
echo github.com/$GITHUB_ORG/modvendor_example

# block: repo
echo https://github.com/$GITHUB_ORG/modvendor_example

# block: setup
mkdir -p $HOME/scratchpad/modvendor_example
cd $HOME/scratchpad/modvendor_example
git init -q
git remote add origin https://github.com/$GITHUB_ORG/modvendor_example
go mod init

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
catfile $PWD/hello.go

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
GOPATH=$(mktemp -d) GOPROXY=file://$HOME/scratchpad/modvendor_example/modvendor go run .

# block: commit and push
git add -A
git commit -q -am 'Initial commit'
git push -q origin master

# block: version details
go version
