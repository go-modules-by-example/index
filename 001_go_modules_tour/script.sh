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
./hello

# block: cat go.mod initial
cat go.mod

# block: no rebuild required
go build
./hello

# block: go list -m demo
go list -m

# block: french hello
LANG=fr ./hello

# block: upgrade
go list -m -u

# block: upgrade text
go get golang.org/x/text
cat go.mod

# block: check go.mod
go list -m

# TODO this should be go test all

# block: go test all
go test github.com/you/hello rsc.io/quote

# block: go test quote
go test rsc.io/quote/...
assert "$? -eq 1" $LINENO

# block: upgrade all
go get -u
cat go.mod

# TODO this should be go test all

# block: test all again
go test github.com/you/hello rsc.io/quote
assert "$? -eq 1" $LINENO

# block: bad output
go build
./hello

export GOPATH=$HOME

# block: list sampler
go list -m -versions rsc.io/sampler

# TODO this should be go test all

# block: specific version
cat go.mod
go get rsc.io/sampler@v1.3.1
go list -m
cat go.mod
go test github.com/you/hello rsc.io/quote

# block: downgrade others
go get rsc.io/sampler@v1.2.0
go list -m
cat go.mod

# TODO this should be go get rsc.io/sampler@none
# TODO this should be go test all

# block: remove dependency
go mod edit -droprequire rsc.io/sampler
go list -m
cat go.mod
go test github.com/you/hello rsc.io/quote

# block: back to latest
go get -u
go list -m

# TODO this should be go test all

# TODO: should be able to use
# go get -u
# below once hack removed

# block: apply exclude
go mod edit -exclude=rsc.io/sampler@v1.99.99
echo "** TODO: REMOVE THIS HACK; see https://github.com/golang/go/issues/26454 **"
cat go.mod
go mod edit -require rsc.io/sampler@v1.3.1
go list -m -versions rsc.io/sampler
go list -m
cat go.mod
go test github.com/you/hello rsc.io/quote
quoteVersion=$(go list -m -f "{{.Version}}" rsc.io/quote)

# block: prepare local quote
git clone -q https://github.com/rsc/quote ../quote

# block: update quote.go
cd ../quote
git checkout -q -b my_quote $quoteVersion
echo "<edit quote.go>"

sed -i 's/return sampler.Hello()/return sampler.Glass()/' quote.go

replace="replace \"rsc.io/quote\" v1.5.2 => \"../quote\""

# block: show replace
echo $replace

# block: apply replace
cd ../hello
go mod edit -replace=rsc.io/quote=../quote
go list -m
go build
./hello

# ensure repo exists and clean up any existing tag
now=$(date +'%Y%m%d%H%M%S_%N')
githubcli repo renameIfExists $GITHUB_ORG/quote-fork quote-fork_$now
githubcli repo transfer $GITHUB_ORG/quote-fork_$now $GITHUB_ORG_ARCHIVE
githubcli repo create $GITHUB_ORG/quote-fork

# block: setup our quote
cd ../quote
git remote add $GITHUB_ORG https://github.com/$GITHUB_ORG/quote-fork
git commit -a -m 'my fork'
git push -q $GITHUB_ORG
git tag v0.0.0-myfork
git push -q $GITHUB_ORG v0.0.0-myfork

# block: use our quote
cd ../hello
go mod edit -replace=rsc.io/quote=github.com/$GITHUB_ORG/quote-fork@v0.0.0-myfork
go list -m
go build
LANG=fr ./hello

# block: vendor
go mod vendor
mkdir -p $GOPATH/src/github.com/you
cp -a . $GOPATH/src/github.com/you/hello
go build -o vhello github.com/you/hello
LANG=es ./vhello

# block: nm compare
go tool nm hello | grep sampler.hello
go tool nm vhello | grep sampler.hello

# block: version details
go version
