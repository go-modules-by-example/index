<!-- __JSON: gobin -m -run myitcv.io/cmd/egrunner script.sh # LONG ONLINE

## "Vendoring" your module download cache

In a pre-modules world, [vendoring](https://github.com/golang/proposal/blob/master/design/25719-go15vendor.md) was (and
indeed remains) a popular way of sharing your code _and its dependencies_ with others, without requiring network access
beyond cloning the source code repository. In the [Vendoring support
guide](../008_vendor_example/README.md) we show how to manage a
`vendor` directory using `go mod vendor`.

In a modules world, the module download cache can be used as a higher fidelity source of module dependencies.

This example shows you how to "vendor" your module download cache alongside your source code.

The resulting repository can be found at {{PrintOut "repo"}}.

### Walk-through

Create a simple module:


```
{{PrintBlock "setup" -}}
```

_Notice, because of the git remote, `go mod init` can be called without any arguments and it resolves to
`{{PrintOut "module"}}`._

Add a simple dependency to a `main` package:


```go
{{PrintBlockOut "example" -}}
```

Run our example as a quick "test":


```
{{PrintBlock "run" -}}
```

Ensure all dependencies are downloaded:

```
{{PrintBlock "go mod download" -}}
```

"Vendor" our dependencies in a module download cache (in the future these commands could become a `go` tool command,
perhaps `go mod modvendor`):

```
{{PrintBlock "fake vendor" -}}
```

(The use of `GOPROXY=file://$GOPATH/pkg/mod/cache/download` is arguably redundant here, but it is sometimes
useful to constrain the modules we use to those previously downloaded, and that's what we are doing here.)

Review the contents of `modvendor`:

```
{{PrintBlock "review modvendor" -}}
```

Verify that `modvendor` can be used as a `GOPROXY` source:


```
{{PrintBlock "check modvendor" -}}
```

The `modvendor` directory can now be committed alongside the source code:

```
{{PrintBlock "commit and push" -}}
```

### Open questions

* The above steps are currently manual; tooling could fix this.
  [The proposal to add a modvendor sub-command](https://github.com/golang/go/issues/27618) explores this further.
* Reviewing "vendored" dependencies is now more involved without further tooling. For example it's no longer possible to
  simply browse the source of a dependency via a GitHub PR when it is added. Again, tooling could help here. As could
some central source of truth for trusted, reviewed modules ([Athens?](https://github.com/gomods/athens))

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## "Vendoring" your module download cache

In a pre-modules world, [vendoring](https://github.com/golang/proposal/blob/master/design/25719-go15vendor.md) was (and
indeed remains) a popular way of sharing your code _and its dependencies_ with others, without requiring network access
beyond cloning the source code repository. In the [Vendoring support
guide](../008_vendor_example/README.md) we show how to manage a
`vendor` directory using `go mod vendor`.

In a modules world, the module download cache can be used as a higher fidelity source of module dependencies.

This example shows you how to "vendor" your module download cache alongside your source code.

The resulting repository can be found at https://github.com/go-modules-by-example/modvendor_example.

### Walk-through

Create a simple module:


```
$ mkdir -p /home/gopher/scratchpad/modvendor_example
$ cd /home/gopher/scratchpad/modvendor_example
$ git init -q
$ git remote add origin https://github.com/go-modules-by-example/modvendor_example
$ go mod init
go: creating new go.mod: module github.com/go-modules-by-example/modvendor_example
```

_Notice, because of the git remote, `go mod init` can be called without any arguments and it resolves to
`github.com/go-modules-by-example/modvendor_example`._

Add a simple dependency to a `main` package:


```go
$ cat /home/gopher/scratchpad/modvendor_example/hello.go
package main

import (
	"fmt"
	"rsc.io/quote"
)

func main() {
	fmt.Println(quote.Hello())
}
```

Run our example as a quick "test":


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

Ensure all dependencies are downloaded:

```
$ go mod download
```

"Vendor" our dependencies in a module download cache (in the future these commands could become a `go` tool command,
perhaps `go mod modvendor`):

```
$ rm -rf modvendor
$ tgp=$(mktemp -d)
$ GOPROXY=file://$GOPATH/pkg/mod/cache/download GOPATH=$tgp go mod download
go: finding rsc.io/quote v1.5.2
go: finding rsc.io/sampler v1.3.0
go: finding golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
$ cp -rp $tgp/pkg/mod/cache/download/ modvendor
$ GOPATH=$tgp go clean -modcache
$ rm -rf $tgp
```

(The use of `GOPROXY=file://$GOPATH/pkg/mod/cache/download` is arguably redundant here, but it is sometimes
useful to constrain the modules we use to those previously downloaded, and that's what we are doing here.)

Review the contents of `modvendor`:

```
$ find modvendor -type f
modvendor/rsc.io/sampler/@v/list
modvendor/rsc.io/sampler/@v/v1.3.0.lock
modvendor/rsc.io/sampler/@v/v1.3.0.mod
modvendor/rsc.io/sampler/@v/v1.3.0.zip
modvendor/rsc.io/sampler/@v/v1.3.0.info
modvendor/rsc.io/sampler/@v/v1.3.0.ziphash
modvendor/rsc.io/sampler/@v/list.lock
modvendor/rsc.io/quote/@v/list
modvendor/rsc.io/quote/@v/v1.5.2.mod
modvendor/rsc.io/quote/@v/v1.5.2.ziphash
modvendor/rsc.io/quote/@v/v1.5.2.zip
modvendor/rsc.io/quote/@v/v1.5.2.lock
modvendor/rsc.io/quote/@v/v1.5.2.info
modvendor/rsc.io/quote/@v/list.lock
modvendor/golang.org/x/text/@v/list
modvendor/golang.org/x/text/@v/v0.0.0-20170915032832-14c0d48ead0c.mod
modvendor/golang.org/x/text/@v/v0.0.0-20170915032832-14c0d48ead0c.ziphash
modvendor/golang.org/x/text/@v/v0.0.0-20170915032832-14c0d48ead0c.info
modvendor/golang.org/x/text/@v/v0.0.0-20170915032832-14c0d48ead0c.lock
modvendor/golang.org/x/text/@v/list.lock
modvendor/golang.org/x/text/@v/v0.0.0-20170915032832-14c0d48ead0c.zip
```

Verify that `modvendor` can be used as a `GOPROXY` source:


```
$ GOPATH=$(mktemp -d) GOPROXY=file:///home/gopher/scratchpad/modvendor_example/modvendor go run .
go: finding rsc.io/quote v1.5.2
go: finding rsc.io/sampler v1.3.0
go: finding golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
go: downloading rsc.io/quote v1.5.2
go: extracting rsc.io/quote v1.5.2
go: downloading rsc.io/sampler v1.3.0
go: extracting rsc.io/sampler v1.3.0
go: downloading golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
go: extracting golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
Hello, world.
```

The `modvendor` directory can now be committed alongside the source code:

```
$ git add -A
$ git commit -q -am 'Initial commit'
$ git push -q origin master
```

### Open questions

* The above steps are currently manual; tooling could fix this.
  [The proposal to add a modvendor sub-command](https://github.com/golang/go/issues/27618) explores this further.
* Reviewing "vendored" dependencies is now more involved without further tooling. For example it's no longer possible to
  simply browse the source of a dependency via a GitHub PR when it is added. Again, tooling could help here. As could
some central source of truth for trusted, reviewed modules ([Athens?](https://github.com/gomods/athens))

### Version details

```
go version go1.12.6 linux/amd64
```

<!-- END -->
