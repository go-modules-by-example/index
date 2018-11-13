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

now=$(date +'%Y%m%d%H%M%S_%N')
githubcli repo create $GITHUB_ORG/listmodgraphwhy_analysis_new_$now

# build listmodwhygraph and incomplete
githubcli repo renameIfExists $GITHUB_ORG/listmodwhygraph listmodwhygraph_$now
githubcli repo transfer $GITHUB_ORG/listmodwhygraph_$now $GITHUB_ORG_ARCHIVE
githubcli repo create $GITHUB_ORG/listmodwhygraph
githubcli repo renameIfExists $GITHUB_ORG/incomplete incomplete_$now
githubcli repo transfer $GITHUB_ORG/incomplete_$now $GITHUB_ORG_ARCHIVE
githubcli repo create $GITHUB_ORG/incomplete

comment
comment "Prepare incomplete"
comment

cd $(mktemp -d)
git init
git remote add origin https://github.com/$GITHUB_ORG/incomplete
cat <<EOD > go.mod
module github.com/$GITHUB_ORG/incomplete
EOD
go mod edit -fmt
cat <<EOD > incomplete.go
package incomplete

import (
	_ "github.com/sirupsen/logrus"
	_ "golang.org/x/tools/go/packages"
)
EOD
gofmt -w incomplete.go
git add -A
git commit -am 'Initial commit'
git push

comment
comment "Prepare listmodwhygraph"
comment

cd $(mktemp -d)
git init
git remote add origin https://github.com/$GITHUB_ORG/listmodwhygraph
cat <<EOD > go.mod
module github.com/$GITHUB_ORG/listmodwhygraph
EOD
go mod edit -fmt
cat <<EOD > listmodwhygraph.go
package listmodwhygraph

import (
	_ "github.com/$GITHUB_ORG/incomplete"
	_ "github.com/kr/pretty"
	_ "github.com/sirupsen/logrus"
)
EOD
gofmt -w listmodwhygraph.go
go mod tidy
git add -A
git commit -am 'Initial commit'
git push

comment
comment "====================="
comment

export baserepo=https://github.com/$GITHUB_ORG/listmodwhygraph

# egrunner_envsubst: +mainmod +baserepo

# block: setup
git clone -q $baserepo $HOME/scratchpad/listmodwhygraph
cd $HOME/scratchpad/listmodwhygraph

# block: base repo
echo $baserepo

# block: org
echo $GITHUB_ORG

# block: repo
echo https://github.com/$GITHUB_ORG/listmodgraphwhy_analysis_new_$now

# behind the scenes download
go mod download

export mainmod=$(go list -m)

# block: main module
go list -m

# block: main module pkgs
go list $mainmod/...

# block: pkgpath
go list

# block: tree main
tree --noreport

# block: listmodwhygraph.go
catfile $PWD/listmodwhygraph.go

# block: tidy
go mod tidy

# block: why tools
go mod why -m golang.org/x/tools

# block: list tools
go list -m -json golang.org/x/tools

# block: go.mod
catfile $PWD/go.mod

# block: go list
go list

# block: go list -deps
go list -deps

# block: go list nonstd
go list -deps -f "{{if not .Standard}}{{.ImportPath}}{{end}}"

# block: go mod why spew
go mod why -m github.com/davecgh/go-spew

# block: go mod why spew pkg
go mod why github.com/davecgh/go-spew/spew

# block: go mod why pty
go mod why -m github.com/kr/pty

# block: go mod why text
go mod why -m github.com/kr/text

# block: graph
go mod graph | sed -Ee 's/@[^[:blank:]]+//g' | sort | uniq >unver.txt
cat <<EOD > graph.dot
digraph {
	graph [overlap=false, size=14];
	root="$(go list -m)";
	node [  shape = plaintext, fontname = "Helvetica", fontsize=24];
	"$(go list -m)" [style = filled, fillcolor = "#E94762"];
EOD
cat unver.txt | awk '{print "\""$1"\" -> \""$2"\""};' >>graph.dot
echo "}" >>graph.dot
sed -i 's+\("github.com/[^/]*/\)\([^"]*"\)+\1\\n\2+g' graph.dot
sfdp -Tsvg -o graph.svg graph.dot

# block: list all
go list -m all

# block: list
go list -m -f "{{if .Indirect}}{{.Path}}{{end}}" all

# block: commit analysis
git remote add analysis https://github.com/$GITHUB_ORG/listmodgraphwhy_analysis_new_$now
git add -A
git commit -am 'Results of analysis'
git push analysis

# block: version details
go version

githubcli repo renameIfExists $GITHUB_ORG/listmodgraphwhy_analysis listmodgraphwhy_analysis_$now
githubcli repo transfer $GITHUB_ORG/listmodgraphwhy_analysis_$now $GITHUB_ORG_ARCHIVE
githubcli repo renameIfExists $GITHUB_ORG/listmodgraphwhy_analysis_new_$now listmodgraphwhy_analysis
