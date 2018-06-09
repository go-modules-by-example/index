<!-- __JSON: egrunner script.sh # LONG ONLINE

### Introduction

How do you handle the situation where a package on which you depend has not been converted to be a
Go module, but you need to "fork" it and depend on the fork?

Whether or not you publish your folk, or maintain it as a local directory, we go into the details
here...

_Add more detail/intro here_

### Walkthrough

Start by getting `vgo` in the usual way:

```
{{PrintBlock "go get vgo" -}}
```

Create ourselves a simple module that depends on an on a module:


```
{{PrintBlock "setup" -}}
```

Now add a tool dependency:


```
{{PrintBlock "add tools dep" -}}
```

Now check our `go.mod` and that everything builds:


```
{{PrintBlock "check" -}}
```

Now vendor and check the contents of our `vendor` directory:

```
{{PrintBlock "vendor" -}}
```


### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

### Introduction

How do you handle the situation where a package on which you depend has not been converted to be a
Go module, but you need to "fork" it and depend on the fork?

Whether or not you publish your folk, or maintain it as a local directory, we go into the details
here...

_Add more detail/intro here_

### Walkthrough

Start by getting `vgo` in the usual way:

```
$ go get -u golang.org/x/vgo
```

Create ourselves a simple module that depends on an on a module:


```
$ mkdir hello
$ cd hello
$ cat <<EOD >hello.go
package main // import "example.com/hello"

import (
	"fmt"
	"rsc.io/quote"
)

func main() {
   fmt.Println(quote.Hello())
}
EOD
$ echo >go.mod
$ vgo build
vgo: resolving import "rsc.io/quote"
vgo: finding rsc.io/quote (latest)
vgo: adding rsc.io/quote v1.5.2
vgo: finding rsc.io/quote v1.5.2
vgo: finding rsc.io/sampler v1.3.0
vgo: finding golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
vgo: downloading rsc.io/quote v1.5.2
vgo: downloading rsc.io/sampler v1.3.0
vgo: downloading golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
$ ./hello
Hello, world.
$ cat go.mod
module example.com/hello

require rsc.io/quote v1.5.2
```

Now add a tool dependency:


```
$ cat <<EOD >>go.mod

require golang.org/x/tools v0.0.0-20180525024113-a5b4c53f6e8b
EOD
$ vgo install golang.org/x/tools/cmd/stringer
vgo: finding golang.org/x/tools v0.0.0-20180525024113-a5b4c53f6e8b
vgo: downloading golang.org/x/tools v0.0.0-20180525024113-a5b4c53f6e8b
```

Now check our `go.mod` and that everything builds:


```
$ cat go.mod
module example.com/hello

require (
	golang.org/x/tools v0.0.0-20180525024113-a5b4c53f6e8b
	rsc.io/quote v1.5.2
)
$ vgo build
```

Now vendor and check the contents of our `vendor` directory:

```
$ vgo vendor
$ cat vendor/vgo.list
MODULE              VERSION
example.com/hello   -
golang.org/x/text   v0.0.0-20170915032832-14c0d48ead0c
golang.org/x/tools  v0.0.0-20180525024113-a5b4c53f6e8b
rsc.io/quote        v1.5.2
rsc.io/sampler      v1.3.0
$ find vendor -type d
vendor
vendor/rsc.io
vendor/rsc.io/sampler
vendor/rsc.io/quote
vendor/golang.org
vendor/golang.org/x
vendor/golang.org/x/text
vendor/golang.org/x/text/internal
vendor/golang.org/x/text/internal/testtext
vendor/golang.org/x/text/internal/ucd
vendor/golang.org/x/text/internal/gen
vendor/golang.org/x/text/internal/tag
vendor/golang.org/x/text/language
vendor/golang.org/x/text/language/testdata
vendor/golang.org/x/text/unicode
vendor/golang.org/x/text/unicode/cldr
```


### Version details

```
go version go1.10.3 linux/amd64 vgo:2018-02-20.1
vgo commit: 203abfb0741bf96c7c5e8dab019f6fe9c89bded3
```

<!-- END -->
