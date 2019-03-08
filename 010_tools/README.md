<!-- __JSON: gobin -m -run myitcv.io/cmd/egrunner script.sh # LONG ONLINE

## Tools as dependencies

Go modules support tools (commands) as dependencies. For example, you might need to install a tool to help with code
generation, or to lint/vet your code. See [the
wiki](https://github.com/golang/go/wiki/Modules#how-can-i-track-tool-dependencies-for-a-module) for more details and
background.

This example shows you how to add tools dependencies to your Go module, specifically the code generator
[`stringer`](https://godoc.org/golang.org/x/tools/cmd/stringer).

The resulting code can be found at {{PrintOut "repo"}}.

### Walk-through

Create a module:

```
{{PrintBlock "setup" -}}
```

Set `GOBIN` (see [`go help environment`](https://golang.org/cmd/go/#hdr-Environment_variables)) to define where tool
dependencies will be installed:

```
{{PrintBlock "set bin target" -}}
```

Add `stringer` as a dependency by importing the package in a build constraint-ignored file. This file will never be
compiled (nor will it compile, because we are importing a `main` package); it is used simply to record the dependency.
The file and the build constraint names are not particularly important, but we choose `tools` for the sake of
consistency:


```go
{{PrintBlockOut "add tool dependency" -}}
```

Install `stringer`:

```
{{PrintBlock "install tool dependency" -}}
```

Our module reflects the dependency:

```
{{PrintBlock "module deps" -}}
```

Verify `stringer` is available on our `PATH`:

```
{{PrintBlock "tool on path" -}}
```

Use `stringer` via a `go:generate` directive:

```go
{{PrintBlockOut "painkiller.go" -}}
```

`go generate` and run the result:

```
{{PrintBlock "go generate and run" -}}
```

Commit and push the results:

```
{{PrintBlock "commit and push" -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## Tools as dependencies

Go modules support tools (commands) as dependencies. For example, you might need to install a tool to help with code
generation, or to lint/vet your code. See [the
wiki](https://github.com/golang/go/wiki/Modules#how-can-i-track-tool-dependencies-for-a-module) for more details and
background.

This example shows you how to add tools dependencies to your Go module, specifically the code generator
[`stringer`](https://godoc.org/golang.org/x/tools/cmd/stringer).

The resulting code can be found at https://github.com/go-modules-by-example/tools.

### Walk-through

Create a module:

```
$ mkdir -p /home/gopher/scratchpad/tools
$ cd /home/gopher/scratchpad/tools
$ git init -q
$ git remote add origin https://github.com/go-modules-by-example/tools
$ go mod init
go: creating new go.mod: module github.com/go-modules-by-example/tools
```

Set `GOBIN` (see [`go help environment`](https://golang.org/cmd/go/#hdr-Environment_variables)) to define where tool
dependencies will be installed:

```
$ export GOBIN=$PWD/bin
$ export PATH=$GOBIN:$PATH
```

Add `stringer` as a dependency by importing the package in a build constraint-ignored file. This file will never be
compiled (nor will it compile, because we are importing a `main` package); it is used simply to record the dependency.
The file and the build constraint names are not particularly important, but we choose `tools` for the sake of
consistency:


```go
$ cat tools.go
// +build tools

package tools

import (
	_ "golang.org/x/tools/cmd/stringer"
)
```

Install `stringer`:

```
$ go install golang.org/x/tools/cmd/stringer
go: finding golang.org/x/tools/cmd/stringer latest
go: finding golang.org/x/tools/cmd latest
go: finding golang.org/x/tools latest
go: downloading golang.org/x/tools v0.0.0-20190308174544-00c44ba9c14f
go: extracting golang.org/x/tools v0.0.0-20190308174544-00c44ba9c14f
go: finding golang.org/x/net v0.0.0-20190213061140-3a22650c66bd
```

Our module reflects the dependency:

```
$ go list -m all
github.com/go-modules-by-example/tools
golang.org/x/net v0.0.0-20190213061140-3a22650c66bd
golang.org/x/tools v0.0.0-20190308174544-00c44ba9c14f
```

Verify `stringer` is available on our `PATH`:

```
$ which stringer
/home/gopher/scratchpad/tools/bin/stringer
```

Use `stringer` via a `go:generate` directive:

```go
$ cat painkiller.go
package main

import "fmt"

//go:generate stringer -type=Pill

type Pill int

const (
	Placebo Pill = iota
	Aspirin
	Ibuprofen
	Paracetamol
	Acetaminophen = Paracetamol
)

func main() {
	fmt.Printf("For headaches, take %v\n", Ibuprofen)
}
```

`go generate` and run the result:

```
$ go generate
$ go run .
For headaches, take Ibuprofen
```

Commit and push the results:

```
$ cat <<EOD >.gitignore
/bin
EOD
$ git add -A
$ git commit -q -am 'Initial commit'
$ git push -q origin
```

### Version details

```
go version go1.12 linux/amd64
```

<!-- END -->
