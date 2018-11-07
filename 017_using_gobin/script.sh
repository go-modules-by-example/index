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

# block: get
GO111MODULE=off go get -u github.com/myitcv/gobin
which gobin

# behind the scenes fix our version
gobin github.com/myitcv/gobin@v0.0.3

# block: fix path
export PATH=$(go env GOPATH)/bin:$PATH
which gobin

# ====================================
# global examples

# behind the scenes fix the version of gohack we install
gobin github.com/rogpeppe/gohack@v1.0.0

# block: gohack
gobin github.com/rogpeppe/gohack

# block: gohack latest
gobin github.com/rogpeppe/gohack@latest

# block: gohack v1.0.0
gobin github.com/rogpeppe/gohack@v1.0.0

# block: gohack print
gobin -p github.com/rogpeppe/gohack@v1.0.0

# block: gohack run
gobin -run github.com/rogpeppe/gohack@v1.0.0 -help
assert "$? -eq 2" $LINENO

# ====================================
# main-module examples

mkdir hello
cd hello
go mod init example.com/hello
cat <<EOD > tools.go
// +build tools

package tools

import (
        _ "golang.org/x/tools/cmd/stringer"
)
EOD
gofmt -w tools.go

# block: module
catfile go.mod

# block: tools
catfile tools.go

# behind the scenes fix the version of gohack we install
gobin -m -p golang.org/x/tools/cmd/stringer@v0.0.0-20181102223251-96e9e165b75e

# block: tools version
gobin -m -p golang.org/x/tools/cmd/stringer

# block: stringer help
gobin -m -run golang.org/x/tools/cmd/stringer -help
assert "$? -eq 2" $LINENO

cat <<EOD | gofmt > main.go
package main

import "fmt"

//go:generate gobin -m -run golang.org/x/tools/cmd/stringer -type=Pill

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

# block: use in go generate
catfile main.go

# block: go generate and run
go generate
go run .

# block: version details
go version
