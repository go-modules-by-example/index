#!/usr/bin/env bash

# **START**

# block: pinned commits
buffaloCommit=354657dfd81584bb82b8b6dff9bb9f6ab22712a8
depCommit=3e697f6afb332b6e12b8b399365e724e2e8dea7e

# block: buffalo commit
echo $buffaloCommit

# block: dep commit
echo $depCommit

echo "machine github.com login $GITHUB_USERNAME password $GITHUB_PAT" >> $HOME/.netrc
echo "" >> $HOME/.netrc
echo "machine api.github.com login $GITHUB_USERNAME password $GITHUB_PAT" >> $HOME/.netrc
git config --global user.email "$GITHUB_USERNAME@example.com"
git config --global user.name "$GITHUB_USERNAME"
git config --global advice.detachedHead false

# block: setup
mkdir /tmp/gopath
export GOPATH=/tmp/gopath
export PATH=$GOPATH/bin:$PATH
cd /tmp/gopath

# block: install dep
go get -u github.com/golang/dep/cmd/dep
cd src/github.com/golang/dep/cmd/dep
git checkout $depCommit
go install

# block: baseline
cd /tmp/gopath
go get -tags sqlite github.com/gobuffalo/buffalo
cd src/github.com/gobuffalo/buffalo
git checkout $buffaloCommit
go get .
go install -tags sqlite
dep ensure
go test -tags sqlite ./...

# TODO add README for the following step

# block: set GO111MODULE
export GO111MODULE=on

# block: go build
go build -tags sqlite

# block: cat go.mod
cat go.mod

# block: go test
go test -tags sqlite ./...

# block: version details
go version
