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

# block: install gohack
cd $(mktemp -d)
go mod init mod
go get -m github.com/rogpeppe/gohack@v1.0.0-alpha.2
go install github.com/rogpeppe/gohack

gohack_version=$(set -e; go list -m github.com/rogpeppe/gohack)

# block: setup
mkdir -p $HOME/scratchpad/using-gohack
cd $HOME/scratchpad/using-gohack
go mod init example.com/blah

cat <<EOD > blah.go
package main

import (
		"fmt"
        "rsc.io/quote"
)

func main() {
	fmt.Println(quote.Hello())
}
EOD
gofmt -w blah.go

# block: simple example
cat blah.go

# block: use a specific version of quote
go get rsc.io/quote@v1.5.1

# block: run example
go run .

# block: gohack quote
gohack get rsc.io/quote

# block: see replace
go mod edit -json

# block: make edit
cd $HOME/gohack/rsc.io/quote
cat <<EOD > quote.go
package quote

func Hello() string {
	return "My hello"
}
EOD

# block: rerun
cd $HOME/scratchpad/using-gohack
go run .

# block: undo
gohack undo rsc.io/quote
go run .

# block: gohack help get
gohack help get

# block: version details
go version
echo "$gohack_version"
