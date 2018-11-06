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
git config --global push.default current

# tidy up if we already have the repo
now=$(date +'%Y%m%d%H%M%S_%N')
githubcli repo renameIfExists $GITHUB_ORG/cyclic cyclic_$now
githubcli repo transfer $GITHUB_ORG/cyclic_$now $GITHUB_ORG_ARCHIVE
githubcli repo create $GITHUB_ORG/cyclic

# block: repo
echo https://github.com/$GITHUB_ORG/cyclic

# block: module
echo github.com/$GITHUB_ORG/cyclic

# block: moduleb
echo github.com/$GITHUB_ORG/cyclic/b

# block: setup
mkdir -p $HOME/scratchpad/cyclic
cd $HOME/scratchpad/cyclic
git init -q
git remote add origin https://github.com/$GITHUB_ORG/cyclic

# prepare module
mkdir a b
cat <<EOD > a/a.go
package a

import "github.com/$GITHUB_ORG/cyclic/b"

const AName = b.BName
EOD
cat <<EOD > b/b.go
package b

const BName = "B"
EOD
cat <<EOD > b/b_test.go
package b_test

import (
		"github.com/$GITHUB_ORG/cyclic/a"
		"fmt"
		"testing"
)

func TestUsingA(t *testing.T) {
		fmt.Printf("Here is A: %v\n", a.AName)
}
EOD
gofmt -w a/a.go b/b.go b/b_test.go

# block: define repo root module
go mod init

# block: tree
tree --noreport

# block: cat a
catfile a/a.go

# block: cat b
catfile b/b.go

# block: cat b_test
catfile b/b_test.go

# block: test
go test -v ./...

# block: commit and push
git add -A
git commit -q -am "Commit 1: initial commit of parent module github.com/$GITHUB_ORG/cyclic"
git rev-parse HEAD
git push -q

# block: create submodule from b
cd $HOME/scratchpad/cyclic/b
go mod init github.com/$GITHUB_ORG/cyclic/b

# block: commit and push b submodule
cd $HOME/scratchpad/cyclic
git add -A
git commit -q -am "Commit 2: create github.com/$GITHUB_ORG/cyclic/b"
git rev-parse HEAD
git push -q

# block: create mutual dependency
go test -v ./...
cd $HOME/scratchpad/cyclic/b
go test -v ./...

# block: list root dependencies
cd $HOME/scratchpad/cyclic
go list -m all

# block: list b dependencies
cd $HOME/scratchpad/cyclic/b
go list -m all

# block: commit mutual dependency
cd $HOME/scratchpad/cyclic
git add -A
git commit -q -am "Commit 3: the mutual dependency"
git rev-parse HEAD
git push -q

# block: version details
go version
