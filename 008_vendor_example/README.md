<!-- __JSON: egrunner script.sh # LONG ONLINE

## Vendoring support

Go 1.5 introduced the concept of [`vendor`](https://github.com/golang/proposal/blob/master/design/25719-go15vendor.md).
Go 1.11 (and modules) retains some backwards compatability for `vendor`, which is useful if you are distributing
code to be built with older, non-module aware versions of Go. This example shows how to use `go mod vendor` to manage
`vendor`.

### Walkthrough

Create a `main` module:


```
{{PrintBlock "setup" -}}
```

Add a simple dependency:


```
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

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## Vendoring support

Go 1.5 introduced the concept of [`vendor`](https://github.com/golang/proposal/blob/master/design/25719-go15vendor.md).
Go 1.11 (and modules) retains some backwards compatability for `vendor`, which is useful if you are distributing
code to be built with older, non-module aware versions of Go. This example shows how to use `go mod vendor` to manage
`vendor`.

### Walkthrough

Create a `main` module:


```
$ mkdir hello
$ cd hello
$ go mod init example.com/hello
```

Add a simple dependency:


```
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
go: finding rsc.io/sampler v1.3.0
go: finding golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
go: downloading rsc.io/sampler v1.3.0
go: downloading golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
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

### Version details

```
go version go1.11 linux/amd64
```

<!-- END -->
