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

# block: simple example part 1
mkdir /tmp/hello
cd /tmp/hello
go mod init github.com/myitcv/hello
assert "$? -eq 0" $LINENO
ls
cat go.mod


# prepare for part 2
cat <<EOD > hello.go
package main

import (
	"fmt"
	"rsc.io/quote"
)

func main() {
	fmt.Println(quote.Hello())
}
EOD
gofmt -w hello.go

# block: simple example part 2
cat hello.go
go build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO

# block: simple example part 3
cat go.mod
go list -m all
assert "$? -eq 0" $LINENO

# block: simple example part 4
go build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO
LANG=fr ./hello
assert "$? -eq 0" $LINENO

# block: simple example part 5
go list -m -u all
assert "$? -eq 0" $LINENO
go get -u golang.org/x/text
assert "$? -eq 0" $LINENO
cat go.mod
go list -m all
assert "$? -eq 0" $LINENO

# block: simple example part 6
go test -short all # TODO

# block: simple example part 7
go test rsc.io/quote/...

# block: simple example part 8
go get -u
cat go.mod

# block: simple example part 9
go test -short all # TODO

# block: simple example part 10
go build
./hello

# block: simple example part 11
go list -m -versions rsc.io/sampler
go get rsc.io/sampler@v1.3.1
go list -m all
cat go.mod

# block: simple example part 12
go test -short all # TODO

# block: simple example part 13
git clone https://github.com/rsc/quote /tmp/quote
assert "$? -eq 0" $LINENO
cd /tmp/quote
quoteVer=$(cd /tmp/hello && go list -m -f "{{.Version}}" rsc.io/quote)
echo $quoteVer
git checkout -b quote_fix $quoteVer
assert "$? -eq 0" $LINENO

sed -i 's/return sampler.Hello()/return sampler.Glass()/' quote.go
assert "$? -eq 0" $LINENO

# block: simple example part 14
cd /tmp/hello
go mod edit -replace 'rsc.io/quote=../quote'
assert "$? -eq 0" $LINENO
go list -m all
assert "$? -eq 0" $LINENO
go build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO

# ensure repo exists and clean up any existing tag
now=$(date +'%Y%m%d%H%M%S_%N')
githubcli repo renameIfExists london-gophers-quote-fork london-gophers-quote-fork_$now
assert "$? -eq 0" $LINENO
githubcli repo create london-gophers-quote-fork
assert "$? -eq 0" $LINENO

# block: simple example part 15
cd /tmp/quote
git remote add myitcv https://github.com/myitcv/london-gophers-quote-fork
assert "$? -eq 0" $LINENO
git commit -a -m 'my fork'
assert "$? -eq 0" $LINENO
git push myitcv
assert "$? -eq 0" $LINENO
git tag v0.0.0-myfork
assert "$? -eq 0" $LINENO
git push myitcv v0.0.0-myfork
assert "$? -eq 0" $LINENO

# block: simple example part 16
cd /tmp/hello
go mod edit -replace 'rsc.io/quote=github.com/myitcv/london-gophers-quote-fork@v0.0.0-myfork'
go list -m all
assert "$? -eq 0" $LINENO
go build
assert "$? -eq 0" $LINENO
LANG=fr ./hello
assert "$? -eq 0" $LINENO

# setup for part 2
cd $(mktemp -d)
export GOPATH=$(mktemp -d)

# block: convert part 1
git clone https://github.com/juju/juju
assert "$? -eq 0" $LINENO
cd juju
assert "$? -eq 0" $LINENO
go mod init
assert "$? -eq 0" $LINENO
go mod tidy
assert "$? -eq 0" $LINENO
