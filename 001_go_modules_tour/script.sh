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

# block: setup
cd $HOME
mkdir hello
cd hello

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

# block: cat hello.go
cat hello.go

# block: initial go build
go mod init github.com/you/hello
go build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO

# block: cat go.mod initial
cat go.mod

# block: no rebuild required
go build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO

# block: go list -m demo
go list -m
assert "$? -eq 0" $LINENO

# block: french hello
LANG=fr ./hello
assert "$? -eq 0" $LINENO

# block: upgrade
go list -m -u
assert "$? -eq 0" $LINENO

# block: upgrade text
go get golang.org/x/text
assert "$? -eq 0" $LINENO
cat go.mod

# block: check go.mod
go list -m
assert "$? -eq 0" $LINENO

# TODO this should be go test all

# block: go test all
go test github.com/you/hello rsc.io/quote
assert "$? -eq 0" $LINENO

# block: go test quote
go test rsc.io/quote/...
assert "$? -eq 1" $LINENO

# block: upgrade all
go get -u
assert "$? -eq 0" $LINENO
cat go.mod

# TODO this should be go test all

# block: test all again
go test github.com/you/hello rsc.io/quote
assert "$? -eq 1" $LINENO

# block: bad output
go build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO

popd > /dev/null
export GOPATH=$HOME

# block: list sampler
go list -m -versions rsc.io/sampler
assert "$? -eq 0" $LINENO

# TODO this should be go test all

# block: specific version
cat go.mod
go get rsc.io/sampler@v1.3.1
assert "$? -eq 0" $LINENO
go list -m
assert "$? -eq 0" $LINENO
cat go.mod
go test github.com/you/hello rsc.io/quote
assert "$? -eq 0" $LINENO

# block: downgrade others
go get rsc.io/sampler@v1.2.0
assert "$? -eq 0" $LINENO
go list -m
assert "$? -eq 0" $LINENO
cat go.mod

# TODO this should be go get rsc.io/sampler@none
# TODO this should be go test all

# block: remove dependency
go mod edit -droprequire rsc.io/sampler
assert "$? -eq 0" $LINENO
go list -m
assert "$? -eq 0" $LINENO
cat go.mod
go test github.com/you/hello rsc.io/quote
assert "$? -eq 0" $LINENO

# block: back to latest
go get -u
assert "$? -eq 0" $LINENO
go list -m
assert "$? -eq 0" $LINENO

# TODO this should be go test all

# TODO: should be able to use
# go get -u
# below once hack removed

# block: apply exclude
go mod edit -exclude=rsc.io/sampler@v1.99.99
echo "** TODO: REMOVE THIS HACK; see https://github.com/golang/go/issues/26454 **"
cat go.mod
go mod edit -require rsc.io/sampler@v1.3.1
assert "$? -eq 0" $LINENO
go list -m -versions rsc.io/sampler
assert "$? -eq 0" $LINENO
go list -m
assert "$? -eq 0" $LINENO
cat go.mod
go test github.com/you/hello rsc.io/quote
assert "$? -eq 0" $LINENO
quoteVersion=$(go list -m -f "{{.Version}}" rsc.io/quote)

# block: prepare local quote
git clone https://github.com/rsc/quote ../quote

# block: update quote.go
cd ../quote
git checkout -b my_quote $quoteVersion
echo "<edit quote.go>"

sed -i 's/return sampler.Hello()/return sampler.Glass()/' quote.go

replace="replace \"rsc.io/quote\" v1.5.2 => \"../quote\""

# block: show replace
echo $replace

# block: apply replace
cd ../hello
go mod edit -replace=rsc.io/quote=../quote
go list -m
assert "$? -eq 0" $LINENO
go build
assert "$? -eq 0" $LINENO
./hello
assert "$? -eq 0" $LINENO

# ensure repo exists and clean up any existing tag
now=$(date +'%Y%m%d%H%M%S_%N')
githubcli repo renameIfExists go-modules-by-example-quote-fork go-modules-by-example-quote-fork_$now
assert "$? -eq 0" $LINENO
githubcli repo create go-modules-by-example-quote-fork
assert "$? -eq 0" $LINENO

# block: setup our quote
cd ../quote
git remote add $GITHUB_USERNAME https://github.com/$GITHUB_USERNAME/go-modules-by-example-quote-fork
assert "$? -eq 0" $LINENO
git commit -a -m 'my fork'
assert "$? -eq 0" $LINENO
git push $GITHUB_USERNAME
assert "$? -eq 0" $LINENO
git tag v0.0.0-myfork
assert "$? -eq 0" $LINENO
git push $GITHUB_USERNAME v0.0.0-myfork
assert "$? -eq 0" $LINENO

# block: use our quote
cd ../hello
go mod edit -replace=rsc.io/quote=github.com/$GITHUB_USERNAME/go-modules-by-example-quote-fork@v0.0.0-myfork
go list -m
assert "$? -eq 0" $LINENO
go build
assert "$? -eq 0" $LINENO
LANG=fr ./hello
assert "$? -eq 0" $LINENO

# block: vendor
go mod vendor
assert "$? -eq 0" $LINENO
mkdir -p $GOPATH/src/github.com/you
cp -a . $GOPATH/src/github.com/you/hello
go build -o vhello github.com/you/hello
assert "$? -eq 0" $LINENO
LANG=es ./vhello
assert "$? -eq 0" $LINENO

# block: nm compare
go tool nm hello | grep sampler.hello
assert "$? -eq 0" $LINENO
go tool nm vhello | grep sampler.hello
assert "$? -eq 0" $LINENO

# block: version details
go version
