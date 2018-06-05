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

Create ourselves a simple module that depends on an "old" Go package (`rsc.io/pdf` at `v0.1.1` is
"old", non-module code):


```
{{PrintBlock "setup" -}}
```

Now we get that specific version of `rsc.io/pdf` that is known to be "old" Go code:


```
{{PrintBlock "vgo get pdf" -}}
```

Now check our code builds and runs:

```
{{PrintBlock "vgo build" -}}
```

Create a local copy of `rsc.io/pdf` and add a replace directive to use it:

```
{{PrintBlock "replace pdf" -}}
```

Now check our code still builds:

```
{{PrintBlock "vgo build fails" -}}
```

It doesn't; seems we need to mark that directory as a Go module with a `go.mod`:


```
{{PrintBlock "create pdf module" -}}
```

Now check our code builds and runs:

```
{{PrintBlock "vgo build check" -}}
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

Create ourselves a simple module that depends on an "old" Go package (`rsc.io/pdf` at `v0.1.1` is
"old", non-module code):


```
$ mkdir hello
$ cd hello
$ cat <<EOD >hello.go
package main // import "example.com/hello"

import (
        "fmt"

        "rsc.io/pdf"
)

func main() {
        fmt.Println(pdf.Point{})
}
EOD
$ echo >go.mod
```

Now we get that specific version of `rsc.io/pdf` that is known to be "old" Go code:


```
$ vgo get rsc.io/pdf@v0.1.1
vgo: finding rsc.io/pdf v0.1.1
vgo: downloading rsc.io/pdf v0.1.1
$ cat go.mod
module example.com/hello

require rsc.io/pdf v0.1.1
```

Now check our code builds and runs:

```
$ vgo build
$ ./hello
{0 0}
```

Create a local copy of `rsc.io/pdf` and add a replace directive to use it:

```
$ git clone https://github.com/rsc/pdf pdf
Cloning into 'pdf'...
$ cd pdf
$ git checkout v0.1.1
HEAD is now at 48d0402... pdf: add a Go import comment
$ cd ..
$ cat <<EOD >>go.mod
replace rsc.io/pdf v0.1.1 => ./pdf
EOD
$ cat go.mod
module example.com/hello

require rsc.io/pdf v0.1.1
replace rsc.io/pdf v0.1.1 => ./pdf
```

Now check our code still builds:

```
$ vgo build
vgo: open /go/hello/pdf/go.mod: no such file or directory
```

It doesn't; seems we need to mark that directory as a Go module with a `go.mod`:


```
$ cd pdf
$ cat <<EOD >go.mod
module rsc.io/pdf
EOD
$ cd ..
```

Now check our code builds and runs:

```
$ vgo build
$ ./hello
{0 0}
```


### Version details

```
go version go1.10.2 linux/amd64 vgo:2018-02-20.1
vgo commit: 6a94eb3b5ccc04453d2fb45c23641e5993118068
```

<!-- END -->
