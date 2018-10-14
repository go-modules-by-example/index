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

# block: use Go 1.10.3
cd /tmp
curl -s https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz | tar -zx
PATH=/tmp/go/bin:$PATH which go
PATH=/tmp/go/bin:$PATH go version

# ensure repo exists and clean up any existing tag
now=$(date +'%Y%m%d%H%M%S_%N')
githubcli repo renameIfExists $GITHUB_ORG/v2-module v2-module_$now
githubcli repo transfer $GITHUB_ORG/v2-module_$now $GITHUB_ORG_ARCHIVE
githubcli repo create $GITHUB_ORG/v2-module

# block: create go module v2
cd $HOME
mkdir hello
cd hello
cat <<EOD > hello.go
package example

import "github.com/$GITHUB_ORG/v2-module/v2/goodbye"

const Name = goodbye.Name
EOD
cat <<EOD > go.mod
module github.com/$GITHUB_ORG/v2-module/v2
EOD
mkdir goodbye
cat <<EOD > goodbye/goodbye.go
package goodbye

const Name = "Goodbye"
EOD
go test ./...
git init
git add -A
git commit -m 'Initial commit'
git remote add origin https://github.com/$GITHUB_ORG/v2-module
git push origin master
git tag v2.0.0
git push origin v2.0.0

# block: Go module use v2 module
cd $HOME
mkdir usehello
cd usehello
cat <<EOD > main.go
package main

import "fmt"
import "github.com/$GITHUB_ORG/v2-module/v2"

func main() {
	fmt.Println(example.Name)
}
EOD
go mod init example.com/usehello
go build
./usehello

# block: GOPATH use v2 module
cd $GOPATH
mkdir -p src/example.com/hello
cd src/example.com/hello
cat <<EOD > main.go
package main

import "fmt"
import "github.com/$GITHUB_ORG/v2-module"

func main() {
	fmt.Println(example.Name)
}
EOD
PATH=/tmp/go/bin:$PATH go get github.com/$GITHUB_ORG/v2-module
PATH=/tmp/go/bin:$PATH go build
./hello

# block: version details
go version
