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

mkdir $HOME/scratchpad

##################

comment
comment "Prepare repos"
comment

now=$(date +'%Y%m%d%H%M%S_%N')
githubcli repo renameIfExists $GITHUB_ORG/specialapi specialapi_$now
githubcli repo transfer $GITHUB_ORG/specialapi_$now $GITHUB_ORG_ARCHIVE
githubcli repo create $GITHUB_ORG/specialapi
githubcli repo renameIfExists $GITHUB_ORG/apidiff apidiff_$now
githubcli repo transfer $GITHUB_ORG/apidiff_$now $GITHUB_ORG_ARCHIVE
githubcli repo create $GITHUB_ORG/apidiff

##################

comment
comment "Prepare specialapi"
comment

cd $(mktemp -d)
git init
git remote add origin https://github.com/$GITHUB_ORG/specialapi
go mod init github.com/$GITHUB_ORG/specialapi
cat <<EOD > specialapi.go
package specialapi

const Number = 42

const RandomNumber = 4

func Name() string {
	return "Rob Pike"
}
EOD
gofmt -w specialapi.go
git add -A
git commit -am 'v1.0.0'
git push
git tag v1.0.0
git push origin v1.0.0
cat <<EOD > specialapi.go
package specialapi

const Number = "42"

const RandomNumber = 6

func FullName() string {
	return "Rob Pike"
}
EOD
gofmt -w specialapi.go
git add -A
git commit -am 'v2.0.0'
git push
git tag v2.0.0
git push origin v2.0.0

##################

comment
comment "Prepare exp CL checkout"
comment

apidiffrepo=https://go.googlesource.com/exp
apidiffpatchset=refs/changes/97/143897/6
exp=$(mktemp -d /tmp/exp_apidiffCL.XXXXXXXXX)
cd $exp
git init
git fetch $apidiffrepo $apidiffpatchset && git checkout FETCH_HEAD
go mod init golang.org/x/exp

##################

comment
comment "Prepare apidiff cmd"
comment

cd $(mktemp -d)
git init
git remote add origin https://github.com/$GITHUB_ORG/apidiff
go mod init github.com/$GITHUB_ORG/apidiff
cat <<EOD > apidiff.go
package main

import (
	"flag"
	"fmt"
	"os"

	"golang.org/x/tools/go/packages"

	"golang.org/x/exp/apidiff"
)

func main() {
	os.Exit(main1())
}

func main1() int {
	if err := mainerr(); err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		return 1
	}
	return 0
}

func mainerr() error {
	flag.Parse()

	if len(flag.Args()) != 2 {
		return fmt.Errorf("need exactly two arguments")
	}

	bef, err := loadSinglePkgFromDir(flag.Args()[0])
	if err != nil {
		return err
	}
	aft, err := loadSinglePkgFromDir(flag.Args()[1])
	if err != nil {
		return err
	}

	changes := apidiff.Changes(bef.Types, aft.Types)

	fmt.Printf("%v", changes)

	return nil
}

func loadSinglePkgFromDir(dir string) (*packages.Package, error) {
	conf := &packages.Config{
		Dir:  dir,
		Mode: packages.LoadTypes,
	}

	pkgs, err := packages.Load(conf, ".")
	if err != nil {
		return nil, fmt.Errorf("failed to go/packages.Load (in %v): %v", dir, err)
	}

	if len(pkgs) != 1 {
		return nil, fmt.Errorf("dir %v resolved to multiple (test) go/packages.Package", dir)
	}

	return pkgs[0], nil
}
EOD
gofmt -w apidiff.go
go mod edit -require=golang.org/x/tools@v0.0.0-20181115011154-2a3f5192be2e
go mod edit -require=golang.org/x/exp@v0.0.0-20181112044915-a3060d491354 -replace=golang.org/x/exp=$exp
go mod tidy
go mod vendor
go install -mod=vendor
git add -A
git commit -am 'Initial commit'
git push

#########################

comment
comment "====================="
comment

# block: apidiff repo
echo https://github.com/$GITHUB_ORG/apidiff

# block: specialapi repo
echo https://github.com/$GITHUB_ORG/specialapi

# block: specialapi package
echo github.com/$GITHUB_ORG/specialapi

# block: setup
cd $HOME/scratchpad
git clone -q --branch v1.0.0 https://github.com/$GITHUB_ORG/specialapi specialapi_v1.0.0
git clone -q --branch v2.0.0 https://github.com/$GITHUB_ORG/specialapi specialapi_v2.0.0

# block: v1.0.0
catfile specialapi_v1.0.0/specialapi.go

# block: v2.0.0
catfile specialapi_v2.0.0/specialapi.go

# block: changes
apidiff specialapi_v1.0.0 specialapi_v2.0.0

# block: version details
go version
echo "apidiff $apidiffrepo $apidiffpatchset"
