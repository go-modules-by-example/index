<!-- __JSON: egrunner script.sh # LONG ONLINE

## "Vendoring" your module download cache

In a pre-modules world, [vendoring](https://github.com/golang/proposal/blob/master/design/25719-go15vendor.md) was a
popular way of sharing your code _and its dependencies_ with others, without requiring network access beyond cloning
the source code repository.

In a modules world, the module download cache can be used as a higher fidelity source of module dependencies.

This example shows you how to "vendor" your module download cache alongside your source code.

### Walkthrough

Create a simple module:


```
{{PrintBlock "setup" -}}
```

Add a simple dependency:


```
{{PrintBlockOut "example" -}}
```

Run our `main` module as a quick "test":


```
{{PrintBlock "run" -}}
```

Ensure all depdencies are downloaded:

```
{{PrintBlock "go mod download" -}}
```

Create our module download cache "vendor" (in the future these commands could become a `go` tool command, perhaps `go
mod modvendor`):

```
{{PrintBlock "fake vendor" -}}
```

Review the contents of `modvendor`:

```
{{PrintBlock "review modvendor" -}}
```

Verify that `modvendor` can be used as a `GOPROXY` source:


```
{{PrintBlock "check modvendor" -}}
```

The `modvendor` directory can now be committed alongside the soure code.

### Open questions

* The above steps are currently manual; tooling (the `go` tool?) can fix this
* Reviewing "vendored" dependencies is now more involved without further tooling. For example it's no longer possible to
  simply browse the source of a dependency via a GitHub PR when it is added. Again, tooling could help here. As could
some central source of truth for trusted, reviewed modules ([Athens?](https://github.com/gomods/athens))

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## "Vendoring" your module download cache

In a pre-modules world, [vendoring](https://github.com/golang/proposal/blob/master/design/25719-go15vendor.md) was a
popular way of sharing your code _and its dependencies_ with others, without requiring network access beyond cloning
the source code repository.

In a modules world, the module download cache can be used as a higher fidelity source of module dependencies.

This example shows you how to "vendor" your module download cache alongside your source code.

### Walkthrough

Create a simple module:


```
$ mkdir hello
$ cd hello
$ go mod init example.com/hello
go: creating new go.mod: module example.com/hello
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

Run our `main` module as a quick "test":


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

Ensure all depdencies are downloaded:

```
$ go mod download
```

Create our module download cache "vendor" (in the future these commands could become a `go` tool command, perhaps `go
mod modvendor`):

```
$ rm -rf modvendor
$ tgp=$(mktemp -d)
$ GOPROXY=file://$GOPATH/pkg/mod/cache/download GOPATH=$tgp go mod download
go: finding rsc.io/quote v1.5.2
go: finding rsc.io/sampler v1.3.0
go: finding golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
$ cp -rp $GOPATH/pkg/mod/cache/download/ modvendor
$ GOPATH=$tgp go clean -modcache
$ rm -rf $tgp
```

Review the contents of `modvendor`:

```
$ find modvendor -type f
modvendor/rsc.io/sampler/@v/list
modvendor/rsc.io/sampler/@v/v1.3.0.mod
modvendor/rsc.io/sampler/@v/v1.3.0.zip
modvendor/rsc.io/sampler/@v/v1.3.0.info
modvendor/rsc.io/sampler/@v/v1.3.0.ziphash
modvendor/rsc.io/quote/@v/list
modvendor/rsc.io/quote/@v/v1.5.2.mod
modvendor/rsc.io/quote/@v/v1.5.2.ziphash
modvendor/rsc.io/quote/@v/v1.5.2.zip
modvendor/rsc.io/quote/@v/v1.5.2.info
modvendor/golang.org/x/text/@v/list
modvendor/golang.org/x/text/@v/v0.0.0-20170915032832-14c0d48ead0c.mod
modvendor/golang.org/x/text/@v/v0.0.0-20170915032832-14c0d48ead0c.ziphash
modvendor/golang.org/x/text/@v/v0.0.0-20170915032832-14c0d48ead0c.info
modvendor/golang.org/x/text/@v/v0.0.0-20170915032832-14c0d48ead0c.zip
```

Verify that `modvendor` can be used as a `GOPROXY` source:


```
$ GOPATH=$(mktemp -d) GOPROXY=file://$PWD/modvendor go run .
go: finding rsc.io/quote v1.5.2
go: finding rsc.io/sampler v1.3.0
go: finding golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
go: downloading rsc.io/quote v1.5.2
go: downloading rsc.io/sampler v1.3.0
go: downloading golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
Hello, world.
```

The `modvendor` directory can now be committed alongside the soure code.

### Open questions

* The above steps are currently manual; tooling (the `go` tool?) can fix this
* Reviewing "vendored" dependencies is now more involved without further tooling. For example it's no longer possible to
  simply browse the source of a dependency via a GitHub PR when it is added. Again, tooling could help here. As could
some central source of truth for trusted, reviewed modules ([Athens?](https://github.com/gomods/athens))

### Version details

```
go version go1.11.1 linux/amd64
```

<!-- END -->
