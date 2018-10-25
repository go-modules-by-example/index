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

mkdir -p $HOME/scratchpad/repos
repo=$HOME/scratchpad/repos/goinfo

cd $(mktemp -d)
go mod init mod
go get -m github.com/marwan-at-work/mod
go install github.com/marwan-at-work/mod/cmd/mod
mod_version=$(go list -m github.com/marwan-at-work/mod)

# =====================================================
# Generic initial commit for all repos

# tidy up if we already have the repos
now=$(date +'%Y%m%d%H%M%S_%N')

for i in maj-subdir maj-branch
do
	r=$(basename $repo-$i)
	githubcli repo renameIfExists $GITHUB_ORG/$r ${r}_$now
	githubcli repo transfer $GITHUB_ORG/${r}_$now $GITHUB_ORG_ARCHIVE
	githubcli repo create $GITHUB_ORG/$r
	mkdir -p $repo-$i
	cd $repo-$i
	git init -q
	git remote add origin https://github.com/$GITHUB_ORG/$r
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
	# block: publish goinfo
	git add -A
	git commit -q -am "Initial commit of $r"
	git push -q origin
	git tag v1.0.0
	git push -q origin v1.0.0
done

# =====================================================
# initial commit is done in each repo
# make strategy specific changes at this point


cd $repo-maj-branch
r=$(basename $PWD)

# block: major branch changes
git log --decorate -1
git branch v1
git push -q origin v1

cat <<EOD | gofmt > designers/designers.go
package designers

import "github.com/$GITHUB_ORG/$r/contributors"

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
mod upgrade

cd $repo-maj-subdir
r=$(basename $PWD)

# block: major subdir changes
git log --decorate -1
mkdir v2
cp -rp $(git ls-tree --name-only HEAD) v2

cd v2
cat <<EOD | gofmt > designers/designers.go
package designers

import "github.com/$GITHUB_ORG/$r/contributors"

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
mod upgrade

# =====================================================

for i in maj-subdir maj-branch
do
	r=$(basename $repo-$i)
	cd $repo-$i
	git add -A
	git commit -q -am "Breaking commit of $r"
	git push -q origin
	git tag v2.0.0
	git push -q origin v2.0.0
done

r="multi-peopleprinter"
githubcli repo renameIfExists $GITHUB_ORG/$r ${r}_$now
githubcli repo transfer $GITHUB_ORG/${r}_$now $GITHUB_ORG_ARCHIVE
githubcli repo create $GITHUB_ORG/$r

# block: use all major versions
mkdir -p $HOME/scratchpad/$r
cd $HOME/scratchpad/$r
git init -q
git remote add origin https://github.com/$GITHUB_ORG/${r}
go mod init

cat <<EOD | gofmt > main.go
package main

import (
	"fmt"
	"os"
	"text/tabwriter"

	majBranch "github.com/$GITHUB_ORG/goinfo-maj-branch/designers"
	majBranch2 "github.com/$GITHUB_ORG/goinfo-maj-branch/v2/designers"

	majSubdir "github.com/$GITHUB_ORG/goinfo-maj-subdir/designers"
	majSubdir2 "github.com/$GITHUB_ORG/goinfo-maj-subdir/v2/designers"
)

func main() {
	tw := tabwriter.NewWriter(os.Stdout, 0, 0, 3, ' ', 0)
	w := func(format string, args ...interface{}) {
		fmt.Fprintf(tw, format, args...)
	}

	w(".../goinfo-maj-branch/designers.Names():\t%v\n", majBranch.Names())
	w(".../goinfo-maj-branch/v2/designers.FullNames():\t%v\n", majBranch2.FullNames())

	w(".../goinfo-maj-subdir/designers.Names():\t%v\n", majSubdir.Names())
	w(".../goinfo-maj-subdir/v2/designers.FullNames():\t%v\n", majSubdir2.FullNames())

	tw.Flush()
}
EOD

# block: multi main
echo // $PWD/main.go
echo
cat $PWD/main.go

# block: run multi main
go run .

# block: commit multi main
git add -A
git commit -q -am "Initial commit of $r"
git push -q origin
git tag v1.0.0
git push -q origin v1.0.0

# block: multi pp package
echo multi-peopleprinter

# block: multi pp repo
echo https://github.com/$GITHUB_ORG/multi-peopleprinter

# block: maj-branch repo
echo https://github.com/$GITHUB_ORG/goinfo-maj-branch

# block: maj-subdir repo
echo https://github.com/$GITHUB_ORG/goinfo-maj-subdir

# block: multi pp mod
echo github.com/$GITHUB_ORG/multi-peopleprinter

# block: maj-branch mod
echo github.com/$GITHUB_ORG/goinfo-maj-branch

# block: maj-subdir mod
echo github.com/$GITHUB_ORG/goinfo-maj-subdir

# block: version details
go version
echo "$mod_version"
