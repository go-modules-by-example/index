#!/usr/bin/env bash

set -u
set -x

assert()
{
  E_PARAM_ERR=98
  E_ASSERT_FAILED=99

  if [ -z "$2" ]
  then
    exit $E_PARAM_ERR
  fi

  lineno=$2

  if [ ! $1 ]
  then
    echo "Assertion failed:  \"$1\""
    echo "File \"$0\", line $lineno"
    exit $E_ASSERT_FAILED
  fi
}

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
export PATH=/tmp/go/bin:$PATH
which go
go version

# block: go get vgo
go get -u golang.org/x/vgo
assert "$? -eq 0" $LINENO

# ensure repo exists and clean up any existing tag
now=$(date +'%Y%m%d%H%M%S_%N')
githubcli repo renameIfExists vgo-by-example-v2-module vgo-by-example-v2-module_$now
assert "$? -eq 0" $LINENO
githubcli repo create vgo-by-example-v2-module
assert "$? -eq 0" $LINENO

# block: create vgo module v2
cd $HOME
mkdir hello
cd hello
cat <<EOD > hello.go
package example

import "github.com/myitcv/vgo-by-example-v2-module/v2/goodbye"

const Name = goodbye.Name
EOD
cat <<EOD > go.mod
module github.com/myitcv/vgo-by-example-v2-module/v2
EOD
mkdir goodbye
cat <<EOD > goodbye/goodbye.go
package goodbye

const Name = "Goodbye"
EOD
vgo test ./...
assert "$? -eq 0" $LINENO
git init
assert "$? -eq 0" $LINENO
git add -A
assert "$? -eq 0" $LINENO
git commit -m 'Initial commit'
assert "$? -eq 0" $LINENO
git remote add origin https://github.com/myitcv/vgo-by-example-v2-module
assert "$? -eq 0" $LINENO
git push origin master
assert "$? -eq 0" $LINENO
git tag v2.0.0
assert "$? -eq 0" $LINENO
git push origin v2.0.0
assert "$? -eq 0" $LINENO

# block: vgo use v2 module
cd $HOME
assert "$? -eq 0" $LINENO
mkdir usehello
assert "$? -eq 0" $LINENO
cd usehello
assert "$? -eq 0" $LINENO
cat <<EOD > main.go
package main // import "example.com/usehello"

import "fmt"
import "github.com/myitcv/vgo-by-example-v2-module/v2"

func main() {
	fmt.Println(example.Name)
}
EOD
echo > go.mod
vgo build
assert "$? -eq 0" $LINENO
./usehello
assert "$? -eq 0" $LINENO

# block: go use v2 module
cd $GOPATH
assert "$? -eq 0" $LINENO
mkdir -p src/example.com/hello
assert "$? -eq 0" $LINENO
cd src/example.com/hello
assert "$? -eq 0" $LINENO
cat <<EOD > main.go
package main // import "example.com/hello"

import "fmt"
import "github.com/myitcv/vgo-by-example-v2-module"

func main() {
	fmt.Println(example.Name)
}
EOD
go get github.com/myitcv/vgo-by-example-v2-module
assert "$? -eq 0" $LINENO
go build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO

# block: version details
vgo version
echo "vgo commit: $(command cd $(go list -f "{{.Dir}}" golang.org/x/vgo); git rev-parse HEAD)"
