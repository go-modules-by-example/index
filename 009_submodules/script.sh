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
githubcli repo renameIfExists $GITHUB_ORG/submodules submodules_$now
githubcli repo transfer $GITHUB_ORG/submodules_$now $GITHUB_ORG_ARCHIVE
githubcli repo create $GITHUB_ORG/submodules

# block: repo
echo https://github.com/$GITHUB_ORG/submodules

# block: setup
mkdir -p $HOME/scratchpad/submodules
cd $HOME/scratchpad/submodules
git init -q
git remote add origin https://github.com/$GITHUB_ORG/submodules

# block: define repo root module
go mod init github.com/$GITHUB_ORG/submodules
git add go.mod
git commit -q -am 'Initial commit'
git push -q

# block: create package b
mkdir b
cd b
cat <<EOD > b.go
package b

const Name = "Gopher"
EOD
go mod init github.com/$GITHUB_ORG/submodules/b
go test

# block: commit and tag b
cd ..
git add b
git commit -q -am 'Add package b'
git push -q
git tag b/v0.1.1
git push -q origin b/v0.1.1

# block: create package a
mkdir a
cd a
cat <<EOD > a.go
package main

import (
	"github.com/$GITHUB_ORG/submodules/b"
	"fmt"
)

const Name = b.Name

func main() {
	fmt.Println(Name)
}
EOD
go mod init github.com/$GITHUB_ORG/submodules/a

# block: run package a
go run .
go list -m github.com/$GITHUB_ORG/submodules/b

# block: commit and tag a
cd ..
git add a
git commit -q -am 'Add package a'
git push -q
git tag a/v1.0.0
git push -q origin a/v1.0.0

# block: final tree output
tree --noreport -rP '*.go|go.mod'

# block: use a
cd $(mktemp -d)
export GOBIN=$PWD/.bin
export PATH=$GOBIN:$PATH
go mod init example.com/blah
go get github.com/$GITHUB_ORG/submodules/a@v1.0.0
a

# block: version details
go version
