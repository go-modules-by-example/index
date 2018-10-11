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
git clone https://github.com/rogpeppe/gohack /tmp/gohack
cd /tmp/gohack
go install

# block: setup
cd $HOME
mkdir using-gohack
cd using-gohack
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
cd $HOME/using-gohack
go run .

# block: undo
gohack undo rsc.io/quote
go run .

# block: gohack help get
gohack help get

# block: version details
go version
cd /tmp/gohack
echo "gohack commit $(git rev-parse HEAD)"
