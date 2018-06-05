<!-- __JSON: egrunner script.sh # LONG ONLINE

Use the Go 1.10 backport branch, specifically:

```
{{PrintBlock "use backport" -}}
```

Get vgo:


```
{{PrintBlock "go get vgo" -}}
```

Create a simple module that depends on v2 of a package, and build:


```
{{PrintBlock "setup" -}}
```

Now try to go get v2:


```
{{PrintBlock "failed go get v2" -}}
```

Note that this works (unsuprisingly):


```
{{PrintBlock "successful go get" -}}
```

Now try and build:

```
{{PrintBlock "successful go build" -}}
```

Now try and list v2 of the package on which we depend:

```
{{PrintBlock "failed go list v2" -}}
```

Note that this works:


```
{{PrintBlock "successful go list" -}}
```

Now verify how go/build behaves with these imports paths:


```
{{PrintBlock "setup go/build test" -}}
```

Run for the v2 import path:


```
{{PrintBlock "failed go run v2" -}}
```

Note that this works:

```
{{PrintBlock "successful go run" -}}
```

-->

Use the Go 1.10 backport branch, specifically:

```
$ cd /tmp
$ git clone https://github.com/golang/go
Cloning into 'go'...
$ cd go/src
$ git checkout 28ae82663a1c57c185312b60a2eae8cf06cc24b4
HEAD is now at 28ae82663a... [release-branch.go1.10] cmd/go: add minimal module-awareness for legacy operation
$ ./make.bash
Building Go cmd/dist using /usr/local/go.
Building Go toolchain1 using /usr/local/go.
Building Go bootstrap cmd/go (go_bootstrap) using Go toolchain1.
Building Go toolchain2 using go_bootstrap and Go toolchain1.
Building Go toolchain3 using go_bootstrap and Go toolchain2.
Building packages and commands for linux/amd64.
---
Installed Go for linux/amd64 in /tmp/go
Installed commands in /tmp/go/bin
$ export PATH=/tmp/go/bin:$PATH
$ which go
/tmp/go/bin/go
$ go version
go version go1.10.2 linux/amd64
```

Get vgo:


```
$ go get -u golang.org/x/vgo
```

Create a simple module that depends on v2 of a package, and build:


```
$ mkdir /tmp/old-go-compat
$ cd /tmp/old-go-compat
$ export GOPATH=$PWD
$ mkdir -p src/example.com/hello
$ cd src/example.com/hello
$ cat <<EOD >hello.go
package main // import "example.com/hello"

import (
	"fmt"
	"github.com/myitcv/vgo_example_compat/v2"
	"github.com/myitcv/vgo_example_compat/v2/sub"
)

func main() {
	fmt.Println(vgo_example_compat.X, sub.Y)
}
EOD
$ echo >go.mod
$ vgo build
vgo: resolving import "github.com/myitcv/vgo_example_compat/v2"
vgo: finding github.com/myitcv/vgo_example_compat/v2 (latest)
vgo: adding github.com/myitcv/vgo_example_compat/v2 v2.0.0
vgo: finding github.com/myitcv/vgo_example_compat/v2 v2.0.0
vgo: downloading github.com/myitcv/vgo_example_compat/v2 v2.0.0
$ ./hello
2 2
```

Now try to go get v2:


```
$ go get github.com/myitcv/vgo_example_compat/v2
package github.com/myitcv/vgo_example_compat/v2: cannot find package "github.com/myitcv/vgo_example_compat/v2" in any of:
	/tmp/go/src/github.com/myitcv/vgo_example_compat/v2 (from $GOROOT)
	/tmp/old-go-compat/src/github.com/myitcv/vgo_example_compat/v2 (from $GOPATH)
```

Note that this works (unsuprisingly):


```
$ go get github.com/myitcv/vgo_example_compat
```

Now try and build:

```
$ go build
$ ./hello
2 2
```

Now try and list v2 of the package on which we depend:

```
$ go list github.com/myitcv/vgo_example_compat/v2
can't load package: package github.com/myitcv/vgo_example_compat/v2: cannot find package "github.com/myitcv/vgo_example_compat/v2" in any of:
	/tmp/go/src/github.com/myitcv/vgo_example_compat/v2 (from $GOROOT)
	/tmp/old-go-compat/src/github.com/myitcv/vgo_example_compat/v2 (from $GOPATH)
```

Note that this works:


```
$ go list github.com/myitcv/vgo_example_compat
github.com/myitcv/vgo_example_compat
```

Now verify how go/build behaves with these imports paths:


```
$ cat <<EOD >run.go
// +build ignore

package main

import (
	"fmt"
	"os"
	"go/build"
)

func main() {
	bpkg, err := build.Import(os.Args[1], ".", 0)
	if err != nil {
		panic(err)
	}
	fmt.Printf("%v\n", bpkg.Dir)
}
EOD
```

Run for the v2 import path:


```
$ go run run.go github.com/myitcv/vgo_example_compat/v2
panic: cannot find package "github.com/myitcv/vgo_example_compat/v2" in any of:
	/tmp/go/src/github.com/myitcv/vgo_example_compat/v2 (from $GOROOT)
	/tmp/old-go-compat/src/github.com/myitcv/vgo_example_compat/v2 (from $GOPATH)

goroutine 1 [running]:
main.main()
	/tmp/old-go-compat/src/example.com/hello/run.go:14 +0x10a
exit status 2
```

Note that this works:

```
$ go run run.go github.com/myitcv/vgo_example_compat
/tmp/old-go-compat/src/github.com/myitcv/vgo_example_compat
```

<!-- END -->
