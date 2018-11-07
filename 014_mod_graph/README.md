<!-- __JSON: gobin -m -run myitcv.io/cmd/egrunner script.sh # LONG ONLINE

## Visually analysing module dependencies

`{{PrintCmd "graph command"}}` prints the module requirement graph in a simple text form. In this guide we explore a
couple of different techniques to visualise this data.

We use the [`github.com/gobuffalo/buffalo`](https://github.com/gobuffalo/buffalo) module as an example because it has a
large number of dependencies which makes for nice visualisations.

### Walk-through

Checkout the Buffalo module:

```
{{PrintBlock "setup" -}}
```

Ensure all dependencies of the Buffalo module are available locally:

```
{{PrintBlock "download" | lineEllipsis 8 -}}
```

Examine the help for `{{PrintCmd "graph command"}}` to understand the output format:

```
{{PrintBlock "graph help" -}}
```

Look at a sample of that output:

```
{{PrintBlock "sample" | lineEllipsis 8 -}}
```

The output from `{{PrintCmd "graph command"}}` contains requirements as listed in modules' `go.mod` files.  Hence we
might see multiple requirements at different minor/patch versions for the same major version of a module. This gets
resolved to a single major version per module during the build phase, but for this analysis we de-duplicate the
requirement graph by module major version:


```
{{PrintBlock "no version" -}}
```

This results in:

```
{{PrintBlock "no version sample" | lineEllipsis 8 -}}
```

Visualise the resulting module dependency graph as a directed graph using [Graphviz's](https://www.graphviz.org/) `dot`
command:

```
{{PrintBlock "dot graph" -}}
```

This results in:

![Module Dependency Graph](https://raw.githubusercontent.com/{{PrintOut "org"}}/mod_graph/master/dag.svg?sanitize=true)

Convert the module requirement graph into a histogram of module dependencies:

```
{{PrintBlock "hist" -}}
```

This results in:

```
{{PrintBlock "hist cat" | lineEllipsis 8 -}}
```

Using [`github.com/ajstarks/deck/cmd/dchart`](https://github.com/ajstarks/deck/blob/master/cmd/dchart/README.md),
generate a radial chart from the histogram data:

```
{{PrintBlock "radial" -}}
```

This results in:

![Dependency Histogram Radial](https://raw.githubusercontent.com/{{PrintOut "org"}}/mod_graph/master/radial.svg?sanitize=true)


Generate a horizontal bar chart from the histogram data:

```
{{PrintBlock "hbar" -}}
```

This results in:

![Dependency Histogram Horizontal Bar](https://raw.githubusercontent.com/{{PrintOut "org"}}/mod_graph/master/hbar.svg?sanitize=true)

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## Visually analysing module dependencies

`go mod graph` prints the module requirement graph in a simple text form. In this guide we explore a
couple of different techniques to visualise this data.

We use the [`github.com/gobuffalo/buffalo`](https://github.com/gobuffalo/buffalo) module as an example because it has a
large number of dependencies which makes for nice visualisations.

### Walk-through

Checkout the Buffalo module:

```
$ cd /home/gopher/scratchpad
$ git clone --depth=1 --branch v0.13.0 https://github.com/gobuffalo/buffalo
Cloning into 'buffalo'...
$ cd buffalo
```

Ensure all dependencies of the Buffalo module are available locally:

```
$ go mod download
go: finding github.com/spf13/cobra v0.0.3
go: finding github.com/gobuffalo/mw-forcessl v0.0.0-20180802152810-73921ae7a130
go: finding github.com/markbates/inflect v1.0.1
go: finding github.com/gobuffalo/mw-contenttype v0.0.0-20180802152300-74f5a47f4d56
go: finding github.com/gobuffalo/mw-paramlogger v0.0.0-20181005191442-d6ee392ec72e
go: finding github.com/markbates/refresh v1.4.10
go: finding github.com/spf13/viper v1.2.1
...
```

Examine the help for `go mod graph` to understand the output format:

```
$ go help mod graph
usage: go mod graph

Graph prints the module requirement graph (with replacements applied)
in text form. Each line in the output has two space-separated fields: a module
and one of its requirements. Each module is identified as a string of the form
path@version, except for the main module, which has no @version suffix.
```

Look at a sample of that output:

```
$ go mod graph
github.com/gobuffalo/buffalo github.com/dgrijalva/jwt-go@v3.2.0+incompatible
github.com/gobuffalo/buffalo github.com/dustin/go-humanize@v1.0.0
github.com/gobuffalo/buffalo github.com/fatih/color@v1.7.0
github.com/gobuffalo/buffalo github.com/fatih/structs@v1.1.0
github.com/gobuffalo/buffalo github.com/gobuffalo/buffalo-plugins@v1.0.4
github.com/gobuffalo/buffalo github.com/gobuffalo/buffalo-pop@v1.0.5
github.com/gobuffalo/buffalo github.com/gobuffalo/envy@v1.6.5
...
```

The output from `go mod graph` contains requirements as listed in modules' `go.mod` files.  Hence we
might see multiple requirements at different minor/patch versions for the same major version of a module. This gets
resolved to a single major version per module during the build phase, but for this analysis we de-duplicate the
requirement graph by module major version:


```
$ go mod graph | sed -Ee 's/@[^[:blank:]]+//g' | sort | uniq >unver.txt
```

This results in:

```
$ cat unver.txt
github.com/gobuffalo/buffalo github.com/cockroachdb/apd
github.com/gobuffalo/buffalo github.com/cockroachdb/cockroach-go
github.com/gobuffalo/buffalo github.com/codegangsta/negroni
github.com/gobuffalo/buffalo github.com/dgrijalva/jwt-go
github.com/gobuffalo/buffalo github.com/dustin/go-humanize
github.com/gobuffalo/buffalo github.com/fatih/color
github.com/gobuffalo/buffalo github.com/fatih/structs
...
```

Visualise the resulting module dependency graph as a directed graph using [Graphviz's](https://www.graphviz.org/) `dot`
command:

```
$ echo "digraph {" >graph.dot
$ echo "graph [rankdir=TB, overlap=false];" >>graph.dot
$ cat unver.txt | awk '{print "\""$1"\" -> \""$2"\""};' >>graph.dot
$ echo "}" >>graph.dot
$ twopi -Tsvg -o dag.svg graph.dot
```

This results in:

![Module Dependency Graph](https://raw.githubusercontent.com/go-modules-by-example/mod_graph/master/dag.svg?sanitize=true)

Convert the module requirement graph into a histogram of module dependencies:

```
$ cat unver.txt | awk '{print $1}' | sort | uniq -c | sort -nr | awk '{print $2 "\t" $1}' >hist.txt
```

This results in:

```
$ cat hist.txt
github.com/gobuffalo/buffalo	60
github.com/gobuffalo/genny	27
github.com/gobuffalo/buffalo-plugins	23
github.com/gobuffalo/fizz	22
github.com/gobuffalo/buffalo-pop	18
github.com/markbates/going	16
github.com/gobuffalo/github_flavored_markdown	16
...
```

Using [`github.com/ajstarks/deck/cmd/dchart`](https://github.com/ajstarks/deck/blob/master/cmd/dchart/README.md),
generate a radial chart from the histogram data:

```
$ dchart -psize=10 -pwidth=30 -left=50 -top=50 -radial -textsize=1.5 -chartitle=Buffalo hist.txt >radial.xml
$ svgdeck -outdir radial -pagesize 1000,1000 radial.xml
```

This results in:

![Dependency Histogram Radial](https://raw.githubusercontent.com/go-modules-by-example/mod_graph/master/radial.svg?sanitize=true)


Generate a horizontal bar chart from the histogram data:

```
$ dchart -hbar -left=40 -top=90 -textsize=1.1 -chartitle=Buffalo hist.txt >hbar.xml
$ svgdeck -outdir hbar -pagesize 1000,1000 hbar.xml
```

This results in:

![Dependency Histogram Horizontal Bar](https://raw.githubusercontent.com/go-modules-by-example/mod_graph/master/hbar.svg?sanitize=true)

### Version details

```
go version go1.11.2 linux/amd64
github.com/ajstarks/deck commit 7b4a8a7c9dfb9243ab16d8a2abd1cedb553e4094
```

<!-- END -->
