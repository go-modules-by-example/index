<!-- __JSON: gobin -m -run myitcv.io/cmd/egrunner script.sh # LONG ONLINE

## Using `go list`, `go mod why` and `go mod graph`

`go list`, `go mod why` and `go mod graph` can be used to analyse modules and packages. In this guide we introduce each
command as we analyse the [`{{PrintOut "main module"}}`]({{PrintOut "base repo"}}) module.

For any of the commands, `go help` provides more details; for example, `go help list` or `go help mod graph`. These help
guides are also available [on the Go website](http://golang.org/cmd/go).

### Walk-through

Clone our example repo ready for analysis:

```
{{PrintBlock "setup" -}}
```

Our main module is:

```
{{PrintBlock "main module" -}}
```

The `-m` flag to `go list` causes list to list modules instead of packages.

The packages in the main module are:

```
{{PrintBlock "main module pkgs" -}}
```

That is to say, the module `{{PrintOut "main module"}}` consists of the single package `{{PrintOut "pkgpath"}}`.

The main module has the following structure:

```
{{PrintBlock "tree main" -}}
```

Examine the single `.go` file in the single package in our main module:

```go
{{PrintBlockOut "listmodwhygraph.go" -}}
```

Ensure the main module's `go.mod` (and `go.sum`) reflects its source code:

```
{{PrintBlock "tidy" | lineEllipsis 3 -}}
```

Building on ["Visually analysing module dependencies"](../014_mod_graph/README.md), use `go mod graph` to look at the
module requirement graph. Remember, each of the nodes in this graph is a module, and an edge `m1 -> m2` indicates that
`m1` requires `m2`. Click the image for a larger version.

![Module Dependency Graph](https://raw.githubusercontent.com/{{PrintOut "org"}}/listmodgraphwhy_analysis/master/graph.svg?sanitize=true)

_See [below](#graphgen) for details on how this graph was generated._

The nodes of this graph can also be given by:

```
{{PrintBlock "list all" | lineEllipsis 4 -}}
```

Looking at the graph and the output of `go list`, the first question that comes to mind is why the module
`golang.org/x/tools` appears to be a dependency of the main module, because it is not imported by `hello.go`.

We can answer that question using `go mod why` which shows us the shortest path from a package in the main module to any
package in the `golang.org/x/tools` module:


```
{{PrintBlock "why tools" -}}
```

This seems to suggest that the dependency exists because of the requirements of
`github.com/go-modules-by-example-forks/incomplete`. But the edge `github.com/go-modules-by-example-forks/incomplete ->
golang.org/x/tools` is definitely not visible on our graph.

Use `go list` again to find out more information about `golang.org/x/tools`:

```
{{PrintBlock "list tools" -}}
```

This shows that `golang.org/x/tools` is an indirect dependency.  Indirect requirements only arise when using modules
that fail to state some of their own dependencies (this includes requirements that have not yet been converted to be
modules) or when explicitly upgrading a module's dependencies ahead of its own stated requirements.

We can also see this from the `// indirect` annotation in the main module's `go.mod`:

```
{{PrintBlockOut "go.mod" -}}
```

In this case, the indirect dependency comes about because the `go.mod` for
`github.com/go-modules-by-example-forks/incomplete` fails to completely state its dependencies; `golang.org/x/tools` is
missing.

Returning to `go list`.

`go list` gives information about packages. By default it lists the import path of packages matching the package
patterns provided. With no arguments `go list` applies to the package in the current directory:

```
{{PrintBlock "go list" -}}
```

We can extend this to include the transitive dependencies of the named packages:

```
{{PrintBlock "go list -deps" | lineEllipsis 5 -}}
```

Use the `-f` flag to exclude standard library dependencies:


```
{{PrintBlock "go list nonstd" -}}
```

Looking at the original module requirement graph, we might ask ourselves, why are there no packages from the modules
`github.com/davecgh/go-spew` and `github.com/kr/pty` in the `go list` output? Use `go mod why -m` to find the shortest
path from a package in the main module to a package in each module.

Firstly `github.com/davecgh/go-spew`:

```
{{PrintBlock "go mod why spew" -}}
```

We see that the package `github.com/davecgh/go-spew/spew` in the module `github.com/davecgh/go-spew` is one such path.
We can therefore expect an identical answer if we ask the question of the package itself (no `-m` this time):

```
{{PrintBlock "go mod why spew pkg" -}}
```

Secondly, `github.com/kr/pty`:

```
{{PrintBlock "go mod why pty" -}}
```

This tells us that there is no package from the `github.com/kr/pty` module in the transitive import graph of of the main
module (`{{PrintOut "main module"}}`).

So why does the `github.com/kr/pty` appear in the module requirement graph? Currently, no command can give us
the answer (something that is being tracked in [#27900](https://github.com/golang/go/issues/27900) and will likely be
fixed in Go 1.12).

But we can clearly see the answer by visually inspecting the requirement graph above. We see that `github.com/kr/text`
requires `github.com/kr/pty`. So `why` does `github.com/kr/text` exist in the requirement graph?

```
{{PrintBlock "go mod why text" -}}
```

For this module we have a concrete answer. So we are now clear that `github.com/kr/text` is in our requirement graph
because it is transitively used by an import of our main package. Furthermore, `github.com/kr/pty` is present because it
is a requirement of `github.com/kr/text` and given the module requirement graph is conservative it reflects all such
requirements.

### Conclusion

`go list`, `go mod graph` and `go mod why` are very powerful tools when it comes to understanding your code and its
dependencies. We have barely scratched the surface of `go list` in this simple guide; as with all tools, read the help
for more information on each, for example. `go help list`.

### <a name="graphgen">Generating the module requirement graph</a>

Generate the module requirement graph:

```
{{PrintBlock "graph" -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## Using `go list`, `go mod why` and `go mod graph`

`go list`, `go mod why` and `go mod graph` can be used to analyse modules and packages. In this guide we introduce each
command as we analyse the [`github.com/go-modules-by-example/listmodwhygraph`](https://github.com/go-modules-by-example/listmodwhygraph) module.

For any of the commands, `go help` provides more details; for example, `go help list` or `go help mod graph`. These help
guides are also available [on the Go website](http://golang.org/cmd/go).

### Walk-through

Clone our example repo ready for analysis:

```
$ git clone -q https://github.com/go-modules-by-example/listmodwhygraph /home/gopher/scratchpad/listmodwhygraph
$ cd /home/gopher/scratchpad/listmodwhygraph
```

Our main module is:

```
$ go list -m
github.com/go-modules-by-example/listmodwhygraph
```

The `-m` flag to `go list` causes list to list modules instead of packages.

The packages in the main module are:

```
$ go list github.com/go-modules-by-example/listmodwhygraph/...
github.com/go-modules-by-example/listmodwhygraph
```

That is to say, the module `github.com/go-modules-by-example/listmodwhygraph` consists of the single package `github.com/go-modules-by-example/listmodwhygraph`.

The main module has the following structure:

```
$ tree --noreport
.
|-- go.mod
|-- go.sum
`-- listmodwhygraph.go
```

Examine the single `.go` file in the single package in our main module:

```go
$ cat /home/gopher/scratchpad/listmodwhygraph/listmodwhygraph.go
package listmodwhygraph

import (
	_ "github.com/go-modules-by-example/incomplete"
	_ "github.com/kr/pretty"
	_ "github.com/sirupsen/logrus"
)
```

Ensure the main module's `go.mod` (and `go.sum`) reflects its source code:

```
$ go mod tidy
```

Building on ["Visually analysing module dependencies"](../014_mod_graph/README.md), use `go mod graph` to look at the
module requirement graph. Remember, each of the nodes in this graph is a module, and an edge `m1 -> m2` indicates that
`m1` requires `m2`. Click the image for a larger version.

![Module Dependency Graph](https://raw.githubusercontent.com/go-modules-by-example/listmodgraphwhy_analysis/master/graph.svg?sanitize=true)

_See [below](#graphgen) for details on how this graph was generated._

The nodes of this graph can also be given by:

```
$ go list -m all
github.com/go-modules-by-example/listmodwhygraph
github.com/davecgh/go-spew v1.1.1
github.com/go-modules-by-example/incomplete v0.0.0-20181113164925-badf929e9e29
...
```

Looking at the graph and the output of `go list`, the first question that comes to mind is why the module
`golang.org/x/tools` appears to be a dependency of the main module, because it is not imported by `hello.go`.

We can answer that question using `go mod why` which shows us the shortest path from a package in the main module to any
package in the `golang.org/x/tools` module:


```
$ go mod why -m golang.org/x/tools
# golang.org/x/tools
github.com/go-modules-by-example/listmodwhygraph
github.com/go-modules-by-example/incomplete
golang.org/x/tools/go/packages
```

This seems to suggest that the dependency exists because of the requirements of
`github.com/go-modules-by-example-forks/incomplete`. But the edge `github.com/go-modules-by-example-forks/incomplete ->
golang.org/x/tools` is definitely not visible on our graph.

Use `go list` again to find out more information about `golang.org/x/tools`:

```
$ go list -m -json golang.org/x/tools
{
	"Path": "golang.org/x/tools",
	"Version": "v0.0.0-20181113152950-150d8ac28524",
	"Time": "2018-11-13T15:29:50Z",
	"Indirect": true,
	"Dir": "/home/gopher/pkg/mod/golang.org/x/tools@v0.0.0-20181113152950-150d8ac28524",
	"GoMod": "/home/gopher/pkg/mod/cache/download/golang.org/x/tools/@v/v0.0.0-20181113152950-150d8ac28524.mod"
}
```

This shows that `golang.org/x/tools` is an indirect dependency.  Indirect requirements only arise when using modules
that fail to state some of their own dependencies (this includes requirements that have not yet been converted to be
modules) or when explicitly upgrading a module's dependencies ahead of its own stated requirements.

We can also see this from the `// indirect` annotation in the main module's `go.mod`:

```
$ cat /home/gopher/scratchpad/listmodwhygraph/go.mod
module github.com/go-modules-by-example/listmodwhygraph

require (
	github.com/go-modules-by-example/incomplete v0.0.0-20181113164925-badf929e9e29
	github.com/kr/pretty v0.1.0
	github.com/sirupsen/logrus v1.2.0
	golang.org/x/tools v0.0.0-20181113152950-150d8ac28524 // indirect
)
```

In this case, the indirect dependency comes about because the `go.mod` for
`github.com/go-modules-by-example-forks/incomplete` fails to completely state its dependencies; `golang.org/x/tools` is
missing.

Returning to `go list`.

`go list` gives information about packages. By default it lists the import path of packages matching the package
patterns provided. With no arguments `go list` applies to the package in the current directory:

```
$ go list
github.com/go-modules-by-example/listmodwhygraph
```

We can extend this to include the transitive dependencies of the named packages:

```
$ go list -deps
errors
internal/cpu
unsafe
internal/bytealg
...
```

Use the `-f` flag to exclude standard library dependencies:


```
$ go list -deps -f "{{if not .Standard}}{{.ImportPath}}{{end}}"
golang.org/x/sys/unix
golang.org/x/crypto/ssh/terminal
github.com/sirupsen/logrus
golang.org/x/tools/go/internal/gcimporter
golang.org/x/tools/go/gcexportdata
golang.org/x/tools/go/internal/cgo
golang.org/x/tools/internal/fastwalk
golang.org/x/tools/internal/gopathwalk
golang.org/x/tools/internal/semver
golang.org/x/tools/go/packages
github.com/go-modules-by-example/incomplete
github.com/kr/text
github.com/kr/pretty
github.com/go-modules-by-example/listmodwhygraph
```

Looking at the original module requirement graph, we might ask ourselves, why are there no packages from the modules
`github.com/davecgh/go-spew` and `github.com/kr/pty` in the `go list` output? Use `go mod why -m` to find the shortest
path from a package in the main module to a package in each module.

Firstly `github.com/davecgh/go-spew`:

```
$ go mod why -m github.com/davecgh/go-spew
# github.com/davecgh/go-spew
github.com/go-modules-by-example/listmodwhygraph
github.com/sirupsen/logrus
github.com/sirupsen/logrus.test
github.com/stretchr/testify/assert
github.com/davecgh/go-spew/spew
```

We see that the package `github.com/davecgh/go-spew/spew` in the module `github.com/davecgh/go-spew` is one such path.
We can therefore expect an identical answer if we ask the question of the package itself (no `-m` this time):

```
$ go mod why github.com/davecgh/go-spew/spew
# github.com/davecgh/go-spew/spew
github.com/go-modules-by-example/listmodwhygraph
github.com/sirupsen/logrus
github.com/sirupsen/logrus.test
github.com/stretchr/testify/assert
github.com/davecgh/go-spew/spew
```

Secondly, `github.com/kr/pty`:

```
$ go mod why -m github.com/kr/pty
# github.com/kr/pty
(main module does not need module github.com/kr/pty)
```

This tells us that there is no package from the `github.com/kr/pty` module in the transitive import graph of of the main
module (`github.com/go-modules-by-example/listmodwhygraph`).

So why does the `github.com/kr/pty` appear in the module requirement graph? Currently, no command can give us
the answer (something that is being tracked in [#27900](https://github.com/golang/go/issues/27900) and will likely be
fixed in Go 1.12).

But we can clearly see the answer by visually inspecting the requirement graph above. We see that `github.com/kr/text`
requires `github.com/kr/pty`. So `why` does `github.com/kr/text` exist in the requirement graph?

```
$ go mod why -m github.com/kr/text
# github.com/kr/text
github.com/go-modules-by-example/listmodwhygraph
github.com/kr/pretty
github.com/kr/text
```

For this module we have a concrete answer. So we are now clear that `github.com/kr/text` is in our requirement graph
because it is transitively used by an import of our main package. Furthermore, `github.com/kr/pty` is present because it
is a requirement of `github.com/kr/text` and given the module requirement graph is conservative it reflects all such
requirements.

### Conclusion

`go list`, `go mod graph` and `go mod why` are very powerful tools when it comes to understanding your code and its
dependencies. We have barely scratched the surface of `go list` in this simple guide; as with all tools, read the help
for more information on each, for example. `go help list`.

### <a name="graphgen">Generating the module requirement graph</a>

Generate the module requirement graph:

```
$ go mod graph | sed -Ee 's/@[^[:blank:]]+//g' | sort | uniq >unver.txt
$ cat <<EOD >graph.dot
digraph {
	graph [overlap=false, size=14];
	root="$(go list -m)";
	node [  shape = plaintext, fontname = "Helvetica", fontsize=24];
	"$(go list -m)" [style = filled, fillcolor = "#E94762"];
EOD
$ cat unver.txt | awk '{print "\""$1"\" -> \""$2"\""};' >>graph.dot
$ echo "}" >>graph.dot
$ sed -i 's+\("github.com/[^/]*/\)\([^"]*"\)+\1\\n\2+g' graph.dot
$ sfdp -Tsvg -o graph.svg graph.dot
```

### Version details

```
go version go1.11.2 linux/amd64
```

<!-- END -->
