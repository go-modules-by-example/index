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

# why is tree not installed by default?!
apt-get update -q > /dev/null 2>&1
apt-get install -q -y graphviz > /dev/null 2>&1

deckCommit=7b4a8a7c9dfb9243ab16d8a2abd1cedb553e4094

# tidy up if we already have the repo
now=$(date +'%Y%m%d%H%M%S_%N')
githubcli repo renameIfExists $GITHUB_ORG/mod_graph mod_graph_$now
githubcli repo transfer $GITHUB_ORG/mod_graph_$now $GITHUB_ORG_ARCHIVE
githubcli repo create $GITHUB_ORG/mod_graph
cd $HOME
mkdir mod_graph
cd mod_graph
git init
git remote add origin https://github.com/$GITHUB_ORG/mod_graph

# block: repo
echo https://github.com/$GITHUB_ORG/mod_graph

# block: org
echo $GITHUB_ORG

# block: setup
cd $HOME
git clone --depth=1 --branch v0.13.0 https://github.com/gobuffalo/buffalo
cd buffalo

# block: download
go mod download

# block: graph command
go mod graph

# block: graph help
go help mod graph

# block: sample
go mod graph

# block: no version
go mod graph | sed -Ee 's/@[^[:blank:]]+//g' | sort | uniq > unver.txt

# block: no version sample
cat unver.txt

# block: dot graph
echo "digraph {" > graph.dot
echo "graph [rankdir=TB, overlap=false];" >> graph.dot
cat unver.txt  | awk '{print "\""$1"\" -> \""$2"\""};' >> graph.dot
echo "}" >> graph.dot
twopi -Tsvg -o dag.svg graph.dot

mkdir radial hbar
pushd $GOPATH
go get github.com/ajstarks/deck/cmd/{dchart,svgdeck}
cd $(go list -f '{{.Dir}}' github.com/ajstarks/deck)
git checkout -f $deckCommit
popd

# block: hist
cat unver.txt | awk '{print $1}' | sort |  uniq -c  | sort -nr | awk '{print $2 "\t" $1}' > hist.txt

# block: hist cat
cat hist.txt

# block: radial
dchart -psize=10 -pwidth=30 -left=50 -top=50 -radial -textsize=1.5 -chartitle=Buffalo hist.txt > radial.xml
svgdeck -outdir radial -pagesize 1000,1000 radial.xml

# block: hbar
dchart -hbar -left=40 -top=90 -textsize=1.1 -chartitle=Buffalo hist.txt > hbar.xml
svgdeck -outdir hbar -pagesize 1000,1000 hbar.xml

cp dag.svg $HOME/mod_graph
cp radial/*.svg $HOME/mod_graph/radial.svg
cp hbar/*.svg $HOME/mod_graph/hbar.svg
cd $HOME/mod_graph
git add -A
git commit -q -am 'Initial commit'
git push -q origin

# block: version details
go version
echo "github.com/ajstarks/deck commit $deckCommit"
