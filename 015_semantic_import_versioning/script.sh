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

# why is tree not installed by default?!
# apt-get update -q > /dev/null 2>&1
# apt-get install -q tree > /dev/null 2>&1

# tidy up if we already have the repos
now=$(date +'%Y%m%d%H%M%S_%N')
githubcli repo renameIfExists $GITHUB_ORG/goinfo goinfo_$now
githubcli repo transfer $GITHUB_ORG/goinfo_$now $GITHUB_ORG_ARCHIVE
githubcli repo create $GITHUB_ORG/goinfo

githubcli repo renameIfExists $GITHUB_ORG/peopleprinter peopleprinter_$now
githubcli repo transfer $GITHUB_ORG/peopleprinter_$now $GITHUB_ORG_ARCHIVE
githubcli repo create $GITHUB_ORG/peopleprinter

# block: gi mod
echo github.com/$GITHUB_ORG/goinfo

# block: pp mod
echo github.com/$GITHUB_ORG/peopleprinter

# block: gi repo
echo https://github.com/$GITHUB_ORG/goinfo

# block: pp repo
echo https://github.com/$GITHUB_ORG/peopleprinter

# block: setup gi structure
mkdir -p $HOME/scratchpad/goinfo
cd $HOME/scratchpad/goinfo
git init -q
git remote add origin https://github.com/$GITHUB_ORG/goinfo
go mod init
mkdir contributors designers

cat <<EOD | gofmt > contributors/contributors.go
package contributors

type Person struct {
	FullName string
}

var all = [...]Person {
	Person{FullName: "Robert Griesemer"},
	Person{FullName: "Rob Pike"},
	Person{FullName: "Ken Thompson"},
	Person{FullName: "Russ Cox"},
	Person{FullName: "Ian Lance Taylor"},
}

func Details() []Person {
	res := all
	return res[:]
}
EOD

cat <<EOD | gofmt > designers/designers.go
package designers

import "github.com/$GITHUB_ORG/goinfo/contributors"

func Names() []string {
	var res []string
	for _, p := range contributors.Details() {
		switch p.FullName {
		case "Rob Pike", "Ken Thompson", "Robert Griesemer":
			res = append(res, p.FullName)
		}
	}
	return res
}
EOD

# block: create contributors
catfile contributors/contributors.go

# block: create designers
catfile designers/designers.go

# block: setup pp structure
cd $HOME/scratchpad
mkdir peopleprinter
cd peopleprinter
git init -q
git remote add origin https://github.com/$GITHUB_ORG/peopleprinter
go mod init

cat <<EOD | gofmt > main.go
package main

import (
	"github.com/$GITHUB_ORG/goinfo/designers"
	"strings"
	"fmt"
)

func main() {
	fmt.Printf("The designers of Go: %v\n", strings.Join(designers.Names(), ", "))
}
EOD

# block: peopleprinter
catfile main.go

# block: pp initial replace
go mod edit -require=github.com/$GITHUB_ORG/goinfo@v0.0.0 -replace=github.com/$GITHUB_ORG/goinfo=$HOME/scratchpad/goinfo

# block: pp replace go.mod
catfile go.mod

# block: run peopleprinter
go run .

# block: publish goinfo
cd $HOME/scratchpad/goinfo
git add -A
git commit -q -am 'Initial commit of goinfo'
git push -q origin
git tag v1.0.0
git push -q origin v1.0.0

# block: use published goinfo v1.0.0
cd $HOME/scratchpad/peopleprinter
go mod edit -require=github.com/$GITHUB_ORG/goinfo@v1.0.0 -dropreplace=github.com/$GITHUB_ORG/goinfo

# block: pp go.mod v2
catfile go.mod

# block: pp run v2
go run .

# block: public pp v1.0.0
git add -A
git commit -q -am 'Initial commit of peopleprinter'
git push -q origin
git tag v1.0.0
git push -q origin v1.0.0

# block: tag v1 branch of gi
cd $HOME/scratchpad/goinfo
git branch v1
git push -q origin v1

cd $HOME/scratchpad/goinfo
cat <<EOD | gofmt > designers/designers.go
package designers

import "github.com/$GITHUB_ORG/goinfo/contributors"

func FullNames() []string {
	var res []string
	for _, p := range contributors.Details() {
		switch p.FullName {
		case "Rob Pike", "Ken Thompson", "Robert Griesemer":
			res = append(res, p.FullName)
		}
	}
	return res
}
EOD

# block: breaking designers
catfile designers/designers.go

# block: install mod
cd $(mktemp -d)
go mod init mod
go get -m github.com/marwan-at-work/mod
go install github.com/marwan-at-work/mod/cmd/mod

mod_version=$(go list -m github.com/marwan-at-work/mod)

# block: ensure mod working
mod -help

# block: mod upgrade
cd $HOME/scratchpad/goinfo
mod upgrade

# block: breaking commit of gi
git add -A
git commit -q -am 'Breaking commit of goinfo'
git push -q origin
git tag v2.0.0
git push -q origin v2.0.0

# block: v1 v2 diffs
echo https://github.com/$GITHUB_ORG/goinfo/compare/v1.0.0...v2.0.0

# use v2
cd $HOME/scratchpad/peopleprinter
cat <<EOD | gofmt > main.go
package main

import (
	"github.com/$GITHUB_ORG/goinfo/designers"
	v2designers "github.com/$GITHUB_ORG/goinfo/v2/designers"
	"strings"
	"fmt"
)

func main() {
	fmt.Printf("The designers of Go: %v\n", strings.Join(designers.Names(), ", "))
	fmt.Printf("The designers of Go: %v\n", strings.Join(v2designers.FullNames(), ", "))
}
EOD

# block: pp v2
catfile main.go

# block: run v2
cd $HOME/scratchpad/peopleprinter
go run .

# block: pp v2 deps
go list -m all

# block: commit pp v2
git add -A
git commit -q -am 'Use goinfo v2 in peopleprinter'
git push -q origin
git tag v1.1.0
git push -q origin v1.1.0

# block: version details
go version
echo "$mod_version"
