<!-- __JSON: gobin -m -run myitcv.io/cmd/egrunner script.sh # LONG ONLINE

## Using `gobin` to install/run tools

In the context of [`golang/go/issues/24250`](https://github.com/golang/go/issues/24250) and
[`golang/go/issues/27653`](https://github.com/golang/go/issues/27653), [`gobin`](https://github.com/myitcv/gobin) is a
work-in-progress experiment that combines aspects of `go get`, `go install` and `go run`.

This guide presents a short introduction to `gobin`.

### Walk-through

Install `gobin`:

```
{{PrintBlock "get" -}}
```

or download a binary from [the latest release](https://github.com/myitcv/gobin/releases).

Update your `PATH` and verify we can find `gobin` in our new `PATH`:

```
{{PrintBlock "fix path" -}}
```

We are now ready to use `gobin`.

### Examples

Install `gohack`:

```
{{PrintBlock "gohack" -}}
```

Install a specific version of `gohack`:

```
{{PrintBlock "gohack v1.0.0" -}}
```

Print the `gobin` cache location of a specific `gohack` version:

```
{{PrintBlock "gohack print" -}}
```

Run a specific `gohack` version:

```
{{PrintBlock "gohack run" | lineEllipsis 4 -}}
```

### Examples: using `-m`

Define a module:

```
{{PrintBlockOut "module" -}}
```

Add a [tool dependency](https://github.com/go-modules-by-example/index/blob/master/010_tools/README.md):

```go
{{PrintBlockOut "tools" -}}
```

Review the version of `stringer` being used:

```
{{PrintBlock "tools version" -}}
```

Check the help for `stringer`:

```
{{PrintBlock "stringer help" | lineEllipsis 5 -}}
```

Use `stringer` via a `go:generate` directive:

```go
{{PrintBlockOut "use in go generate" -}}
```

Generate and run as a "test":

```
{{PrintBlock "go generate and run" -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## Using `gobin` to install/run tools

In the context of [`golang/go/issues/24250`](https://github.com/golang/go/issues/24250) and
[`golang/go/issues/27653`](https://github.com/golang/go/issues/27653), [`gobin`](https://github.com/myitcv/gobin) is a
work-in-progress experiment that combines aspects of `go get`, `go install` and `go run`.

This guide presents a short introduction to `gobin`.

### Walk-through

Install `gobin`:

```
$ GO111MODULE=off go get -u github.com/myitcv/gobin
$ which gobin
/home/gopher/bin/gobin
```

or download a binary from [the latest release](https://github.com/myitcv/gobin/releases).

Update your `PATH` and verify we can find `gobin` in our new `PATH`:

```
$ export PATH=$(go env GOPATH)/bin:$PATH
$ which gobin
/home/gopher/bin/gobin
```

We are now ready to use `gobin`.

### Examples

Install `gohack`:

```
$ gobin github.com/rogpeppe/gohack
Installed github.com/rogpeppe/gohack@v1.0.0 to /home/gopher/bin/gohack
```

Install a specific version of `gohack`:

```
$ gobin github.com/rogpeppe/gohack@v1.0.0
Installed github.com/rogpeppe/gohack@v1.0.0 to /home/gopher/bin/gohack
```

Print the `gobin` cache location of a specific `gohack` version:

```
$ gobin -p github.com/rogpeppe/gohack@v1.0.0
/home/gopher/.cache/gobin/github.com/rogpeppe/gohack/@v/v1.0.0/github.com/rogpeppe/gohack/gohack
```

Run a specific `gohack` version:

```
$ gobin -run github.com/rogpeppe/gohack@v1.0.0 -help
The gohack command checks out Go module dependencies
into a directory where they can be edited, and adjusts
the go.mod file appropriately.
...
```

### Examples: using `-m`

Define a module:

```
$ cat go.mod
module example.com/hello
```

Add a [tool dependency](https://github.com/go-modules-by-example/index/blob/master/010_tools/README.md):

```go
$ cat tools.go
// +build tools

package tools

import (
	_ "golang.org/x/tools/cmd/stringer"
)
```

Review the version of `stringer` being used:

```
$ gobin -m -p golang.org/x/tools/cmd/stringer
/home/gopher/hello/.gobincache/golang.org/x/tools/@v/v0.0.0-20181102223251-96e9e165b75e/golang.org/x/tools/cmd/stringer/stringer
```

Check the help for `stringer`:

```
$ gobin -m -run golang.org/x/tools/cmd/stringer -help
Usage of stringer:
	stringer [flags] -type T [directory]
	stringer [flags] -type T files... # Must be a single package
For more information, see:
...
```

Use `stringer` via a `go:generate` directive:

```go
$ cat main.go
package main

import "fmt"

//go:generate gobin -m -run golang.org/x/tools/cmd/stringer -type=Pill

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

Generate and run as a "test":

```
$ go generate
$ go run .
For headaches, take Ibuprofen
```

### Version details

```
go version go1.11.2 linux/amd64
```

<!-- END -->
