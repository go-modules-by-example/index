<!-- __JSON: egrunner script.sh # LONG ONLINE

## Tools as dependencies

Go supports tools as dependencies of modules. For example, you might need to install a tool to help with code
generation, or to lint/vet your code. This example shows you how.

### Walkthrough

First, ceate ourselves an example module. This example will require
[`stringer`](https://godoc.org/golang.org/x/tools/cmd/stringer) to help with code generation.

```
{{PrintBlock "setup" -}}
```

We set `GOBIN` (see [`go help environment`](https://golang.org/cmd/go/#hdr-Environment_variables)) to define where we
want our tool dependencies to be installed:


```
{{PrintBlock "set bin target" -}}
```

We add `stringer` as a dependency by importing the package in a build constraint ignored file. This file will never be
compiled (nor will not compile, because we are importing a `main` package); it is used simply to record the dependency.
The file name and the build constraint are not particularly important, but we go with `tools` for the sake of
consistency:


```
{{PrintBlockOut "add tool dependency" -}}
```

Now we install `stringer`:

```
{{PrintBlock "install tool dependency" -}}
```

We can see that `stringer` is now available on our `PATH`:


```
{{PrintBlock "tool on path" -}}
```

Now let's use `stringer` via a `go:generate` directive:


```
{{PrintBlockOut "painkiller.go" -}}
```

Next run `go generate` and run the result:

```
{{PrintBlock "go generate and run" -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## Tools as dependencies

Go supports tools as dependencies of modules. For example, you might need to install a tool to help with code
generation, or to lint/vet your code. This example shows you how.

### Walkthrough

First, ceate ourselves an example module. This example will require
[`stringer`](https://godoc.org/golang.org/x/tools/cmd/stringer) to help with code generation.

```
$ mkdir /tmp/go-modules-by-example-tools
$ cd /tmp/go-modules-by-example-tools
$ go mod init example.com/blah/painkiller
go: creating new go.mod: module example.com/blah/painkiller
```

We set `GOBIN` (see [`go help environment`](https://golang.org/cmd/go/#hdr-Environment_variables)) to define where we
want our tool dependencies to be installed:


```
$ export GOBIN=$PWD/bin
$ export PATH=$GOBIN:$PATH
```

We add `stringer` as a dependency by importing the package in a build constraint ignored file. This file will never be
compiled (nor will not compile, because we are importing a `main` package); it is used simply to record the dependency.
The file name and the build constraint are not particularly important, but we go with `tools` for the sake of
consistency:


```
// +build tools

package tools

import (
	_ "golang.org/x/tools/cmd/stringer"
)
```

Now we install `stringer`:

```
$ go install golang.org/x/tools/cmd/stringer
go: finding golang.org/x/tools/cmd/stringer latest
go: finding golang.org/x/tools/cmd latest
go: finding golang.org/x/tools latest
go: downloading golang.org/x/tools v0.0.0-20180904205237-0aa4b8830f48
```

We can see that `stringer` is now available on our `PATH`:


```
$ which stringer
/tmp/go-modules-by-example-tools/bin/stringer
```

Now let's use `stringer` via a `go:generate` directive:


```
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

Next run `go generate` and run the result:

```
$ go generate
$ go run .
For headaches, take Ibuprofen
```

### Version details

```
go version go1.11 linux/amd64
```

<!-- END -->
