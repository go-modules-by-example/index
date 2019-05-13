#!/usr/bin/env bash

# **START**

# tidy up if we already have the repo
now=$(date +'%Y%m%d%H%M%S_%N')
githubcli repo renameIfExists $GITHUB_ORG/buffalo buffalo_$now
githubcli repo transfer $GITHUB_ORG/buffalo_$now $GITHUB_ORG_ARCHIVE
githubcli repo create $GITHUB_ORG/buffalo

# block: repo
echo https://github.com/$GITHUB_ORG/buffalo

# block: pinned commits
buffaloCommit=354657dfd81584bb82b8b6dff9bb9f6ab22712a8
depCommit=5025d70ef6f298075c16c835a78924f2edd37502

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
export GOPATH=$(mktemp -d)
export PATH=$GOPATH/bin:$PATH
cd $GOPATH

# block: install dep
go get -u github.com/golang/dep/cmd/dep
cd src/github.com/golang/dep/cmd/dep
git checkout $depCommit
go install

# block: get buffalo
cd $GOPATH
go get -tags sqlite github.com/gobuffalo/buffalo
cd src/github.com/gobuffalo/buffalo
git checkout $buffaloCommit
go get .

# block: baseline
dep ensure
go test -tags sqlite ./...

# block: set GO111MODULE
export GO111MODULE=on

# block: go mod init
go mod init

# block: go mod tidy
go mod tidy

# block: cat go.mod
cat go.mod

# block: go test
go test -tags sqlite ./...

# block: commit
rm -rf vendor Gopkg.toml
git remote add $GITHUB_ORG https://github.com/$GITHUB_ORG/buffalo
git checkout -q -b migrate_buffalo
git add go.mod go.sum
git commit -am 'Convert to a Go module'
git push -q $GITHUB_ORG

# block: version details
go version
