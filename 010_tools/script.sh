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
githubcli repo renameIfExists $GITHUB_ORG/tools tools_$now
githubcli repo transfer $GITHUB_ORG/tools_$now $GITHUB_ORG_ARCHIVE
githubcli repo create $GITHUB_ORG/tools

# block: repo
echo https://github.com/$GITHUB_ORG/tools

# block: setup
cd $HOME
mkdir tools
cd tools
git init -q
git remote add origin https://github.com/$GITHUB_ORG/tools
go mod init

# block: set bin target
export GOBIN=$PWD/bin
export PATH=$GOBIN:$PATH

cat <<EOD > tools.go
// +build tools

package tools

import (
        _ "golang.org/x/tools/cmd/stringer"
)
EOD
gofmt -w tools.go

# block: add tool dependency
cat tools.go

# block: install tool dependency
go install golang.org/x/tools/cmd/stringer

# block: module deps
go list -m all

# block: tool on path
which stringer

cat <<EOD > painkiller.go
package main

import "fmt"

//go:generate stringer -type=Pill

type Pill int

const (
	Placebo Pill = iota
	Aspirin
	Ibuprofen
	Paracetamol
	Acetaminophen = Paracetamol
)

func main() {
	fmt.Printf("For headaches, take %v\n", Ibuprofen)
}
EOD
gofmt -w painkiller.go

# block: painkiller.go
cat painkiller.go

# block: go generate and run
go generate
go run .

# block: commit and push
cat <<EOD > .gitignore
/bin
EOD
git add -A
git commit -q -am 'Initial commit'
git push -q origin

# block: version details
go version
