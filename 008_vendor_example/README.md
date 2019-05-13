<!-- __JSON: gobin -m -run myitcv.io/cmd/egrunner script.sh # LONG ONLINE

## Vendoring support

Go 1.5 introduced the concept of [`vendor`](https://github.com/golang/proposal/blob/master/design/25719-go15vendor.md).
Go 1.11 (and modules) retains support for `vendor`. This is useful to ensure that all files used for a build are stored
together in a single file tree. In addition, this allows interoperation with older versions of Go given older versions
understand how to consume the `vendor` directory created by `go mod vendor`.

More information about the relationship between Go modules and vendor can be found
[in the vendoring FAQ on the wiki](https://github.com/golang/go/wiki/Modules#how-do-i-use-vendoring-with-modules-is-vendoring-going-away).

This example shows how to use `go mod vendor` to manage the `vendor` directory.

### Walkthrough

Create a module:


```
{{PrintBlock "setup" -}}
```

Add a simple dependency to a `main` package in our module:


```go
{{PrintBlockOut "example" -}}
```

Run as a quick "test":


```
{{PrintBlock "run" -}}
```


Review our dependencies:


```
{{PrintBlock "review deps" -}}
```

Vendor our dependencies:


```
{{PrintBlock "vendor" -}}
```

Review the contents of `vendor`:

```
{{PrintBlock "review vendor" -}}
```

Re-run our "test" using `vendor`:

```
{{PrintBlock "run with vendor" -}}
```

For more information about the `-mod` flag see [`go help
modules`](https://golang.org/cmd/go/#hdr-Maintaining_module_requirements).

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## Vendoring support

Go 1.5 introduced the concept of [`vendor`](https://github.com/golang/proposal/blob/master/design/25719-go15vendor.md).
Go 1.11 (and modules) retains support for `vendor`. This is useful to ensure that all files used for a build are stored
together in a single file tree. In addition, this allows interoperation with older versions of Go given older versions
understand how to consume the `vendor` directory created by `go mod vendor`.

More information about the relationship between Go modules and vendor can be found
[in the vendoring FAQ on the wiki](https://github.com/golang/go/wiki/Modules#how-do-i-use-vendoring-with-modules-is-vendoring-going-away).

This example shows how to use `go mod vendor` to manage the `vendor` directory.

### Walkthrough

Create a module:


```
$ mkdir -p /home/gopher/scratchpad/hello
$ cd /home/gopher/scratchpad/hello
$ go mod init example.com/hello
go: creating new go.mod: module example.com/hello
```

Add a simple dependency to a `main` package in our module:


```go
$ cat hello.go
package main

import (
	"fmt"
	"rsc.io/quote"
)

func main() {
	fmt.Println(quote.Hello())
}
```

Run as a quick "test":


```
$ go run .
go: finding rsc.io/quote v1.5.2
go: downloading rsc.io/quote v1.5.2
go: extracting rsc.io/quote v1.5.2
go: finding rsc.io/sampler v1.3.0
go: finding golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
go: downloading rsc.io/sampler v1.3.0
go: extracting rsc.io/sampler v1.3.0
go: downloading golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
go: extracting golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
Hello, world.
```


Review our dependencies:


```
$ go list -m all
example.com/hello
golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
rsc.io/quote v1.5.2
rsc.io/sampler v1.3.0
```

Vendor our dependencies:


```
$ go mod vendor
```

Review the contents of `vendor`:

```
$ cat vendor/modules.txt
# golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
golang.org/x/text/language
golang.org/x/text/internal/tag
# rsc.io/quote v1.5.2
rsc.io/quote
# rsc.io/sampler v1.3.0
rsc.io/sampler
$ find vendor -type d
vendor
vendor/rsc.io
vendor/rsc.io/sampler
vendor/rsc.io/quote
vendor/golang.org
vendor/golang.org/x
vendor/golang.org/x/text
vendor/golang.org/x/text/internal
vendor/golang.org/x/text/internal/tag
vendor/golang.org/x/text/language
```

Re-run our "test" using `vendor`:

```
$ go run -mod=vendor .
Hello, world.
```

For more information about the `-mod` flag see [`go help
modules`](https://golang.org/cmd/go/#hdr-Maintaining_module_requirements).

### Version details

```
go version go1.12.5 linux/amd64
```

<!-- END -->
