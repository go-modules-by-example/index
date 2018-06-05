<!-- __JSON: egrunner script.sh # LONG ONLINE

### Intro

_Some background here on the history of gopkg.in, major version numbers in paths etc._

### Getting started

As ever, start by ensuring vgo is installed and up to date:

```
{{PrintBlock "go get vgo" -}}
```

### Hello, world

Let's write the YAML equivalent of Hello World. Create a directory outside
your GOPATH/src tree and change into it:

```
{{PrintBlock "setup" -}}
```

Then create a file hello.go which uses the original v1 of the yaml package:

```go
{{PrintOut "cat hello.go" -}}
```

Create an empty go.mod file to mark the root of this module, and then build and
run your new program:

```
{{PrintBlock "initial vgo build" -}}
```

Notice how vgo resolves gopkg.in/yaml.v1, something we can see by inspecting the go.mod
file:

```
{{PrintBlock "cat go.mod initial" -}}
```

Now let's assume there was a breaking change announced in the yaml package which necessitated a
major version bump, to v2.x.x. We update hello.go:


```go
{{PrintOut "cat hello.go v2" -}}
```

Now we vgo build again; notice the resolution to v2 of the yaml package this time around:

```
{{PrintBlock "vgo build v2" -}}
```

We can check go.mod for the exact version that was resolved:

```
{{PrintBlock "cat go.mod v2" -}}
```

Notice that the previously resolved v1 of the yaml package remains in the go.mod file. Pruning or trimming of
dependencies is being discussed in https://github.com/golang/go/issues/24101.

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

### Intro

_Some background here on the history of gopkg.in, major version numbers in paths etc._

### Getting started

As ever, start by ensuring vgo is installed and up to date:

```
$ go get -u golang.org/x/vgo
```

### Hello, world

Let's write the YAML equivalent of Hello World. Create a directory outside
your GOPATH/src tree and change into it:

```
$ cd $HOME
$ mkdir hello
$ cd hello
```

Then create a file hello.go which uses the original v1 of the yaml package:

```go
package main // import "github.com/you/hello"

import (
	"fmt"
	"gopkg.in/yaml.v1"
	"log"
)

type T struct {
	F int "a,omitempty"
	B int
}

func main() {
	t := &T{F: 1}
	out, err := yaml.Marshal(t)
	if err != nil {
		log.Fatalf("cannot marshal %#v: %v", t, err)
	}
	fmt.Printf("we got %q\n", out)
}
```

Create an empty go.mod file to mark the root of this module, and then build and
run your new program:

```
$ echo >go.mod
$ vgo build
vgo: resolving import "gopkg.in/yaml.v1"
vgo: finding gopkg.in/yaml.v1 (latest)
vgo: adding gopkg.in/yaml.v1 v1.0.0-20140924161607-9f9df34309c0
vgo: finding gopkg.in/yaml.v1 v1.0.0-20140924161607-9f9df34309c0
vgo: downloading gopkg.in/yaml.v1 v1.0.0-20140924161607-9f9df34309c0
$ ./hello
we got "a: 1\nb: 0\n"
```

Notice how vgo resolves gopkg.in/yaml.v1, something we can see by inspecting the go.mod
file:

```
$ cat go.mod
module github.com/you/hello

require gopkg.in/yaml.v1 v1.0.0-20140924161607-9f9df34309c0
```

Now let's assume there was a breaking change announced in the yaml package which necessitated a
major version bump, to v2.x.x. We update hello.go:


```go
package main // import "github.com/you/hello"

import (
	"fmt"
	"gopkg.in/yaml.v2"
	"log"
)

type T struct {
	F int "a,omitempty"
	B int
}

func main() {
	t := &T{F: 1}
	out, err := yaml.Marshal(t)
	if err != nil {
		log.Fatalf("cannot marshal %#v: %v", t, err)
	}
	fmt.Printf("we got %q\n", out)
}
```

Now we vgo build again; notice the resolution to v2 of the yaml package this time around:

```
$ vgo build
vgo: resolving import "gopkg.in/yaml.v2"
vgo: finding gopkg.in/yaml.v2 (latest)
vgo: adding gopkg.in/yaml.v2 v2.2.1
vgo: finding gopkg.in/yaml.v2 v2.2.1
vgo: finding gopkg.in/check.v1 v0.0.0-20161208181325-20d25e280405
vgo: downloading gopkg.in/yaml.v2 v2.2.1
$ ./hello
we got "a: 1\nb: 0\n"
```

We can check go.mod for the exact version that was resolved:

```
$ cat go.mod
module github.com/you/hello

require (
	gopkg.in/yaml.v1 v1.0.0-20140924161607-9f9df34309c0
	gopkg.in/yaml.v2 v2.2.1
)
```

Notice that the previously resolved v1 of the yaml package remains in the go.mod file. Pruning or trimming of
dependencies is being discussed in https://github.com/golang/go/issues/24101.

### Version details

```
go version go1.10.2 linux/amd64 vgo:2018-02-20.1
vgo commit: 416f375193bdc882469e470452be5d856646df76
```

<!-- END -->
