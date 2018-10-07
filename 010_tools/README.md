<!-- __JSON: egrunner script.sh # LONG ONLINE

## Tools as dependencies

Go supports tools as dependencies of modules. For example, you might need to install a tool to help with code
generation, or to lint/vet your code. This example shows you how.

### Walkthrough

First, ceate an example module. This example will require
[`stringer`](https://godoc.org/golang.org/x/tools/cmd/stringer) to help with code generation.

```
{{PrintBlock "setup" -}}
```

Set `GOBIN` (see [`go help environment`](https://golang.org/cmd/go/#hdr-Environment_variables)) to define where tool
dependencies will be installed:


```
{{PrintBlock "set bin target" -}}
```

Add `stringer` as a dependency by importing the package in a build constraint ignored file. This file will never be
compiled (nor will not compile, because we are importing a `main` package); it is used simply to record the dependency.
The file and the build constraint names are not particularly important, but we choose `tools` for the sake of
consistency:


```
{{PrintBlockOut "add tool dependency" -}}
```

Install `stringer`:

```
{{PrintBlock "install tool dependency" -}}
```

The module reflects the dependency:

```
{{PrintBlock "module deps" -}}
```

`stringer` is available on our `PATH`:


```
{{PrintBlock "tool on path" -}}
```

Let's use `stringer` via a `go:generate` directive:


```
{{PrintBlockOut "painkiller.go" -}}
```

`go generate` and run the result:

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

First, ceate an example module. This example will require
[`stringer`](https://godoc.org/golang.org/x/tools/cmd/stringer) to help with code generation.

```
$ mkdir /tmp/tools
$ cd /tmp/tools
$ go mod init example.com/blah/painkiller
go: creating new go.mod: module example.com/blah/painkiller
```

Set `GOBIN` (see [`go help environment`](https://golang.org/cmd/go/#hdr-Environment_variables)) to define where tool
dependencies will be installed:


```
$ export GOBIN=$PWD/bin
$ export PATH=$GOBIN:$PATH
```

Add `stringer` as a dependency by importing the package in a build constraint ignored file. This file will never be
compiled (nor will not compile, because we are importing a `main` package); it is used simply to record the dependency.
The file and the build constraint names are not particularly important, but we choose `tools` for the sake of
consistency:


```
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
go: downloading golang.org/x/tools v0.0.0-20181006002542-f60d9635b16a
```

The module reflects the dependency:

```
$ go mod edit -json
{
	"Module": {
		"Path": "example.com/blah/painkiller"
	},
	"Require": [
		{
			"Path": "golang.org/x/tools",
			"Version": "v0.0.0-20181006002542-f60d9635b16a",
			"Indirect": true
		}
	],
	"Exclude": null,
	"Replace": null
}
```

`stringer` is available on our `PATH`:


```
$ which stringer
/tmp/tools/bin/stringer
```

Let's use `stringer` via a `go:generate` directive:


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

`go generate` and run the result:

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
