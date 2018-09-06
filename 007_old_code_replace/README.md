<!-- __JSON: egrunner script.sh # LONG ONLINE

### Introduction

How do you handle the situation where a package on which you depend has not been converted to be a
Go module, but you need to "fork" it and depend on the fork?

Whether or not you publish your folk, or maintain it as a local directory, we go into the details
here...

_Add more detail/intro here_

### Walkthrough

Create ourselves a simple module that depends on an "old" Go package (`rsc.io/pdf` at `v0.1.1` is
"old", non-module code):


```
{{PrintBlock "setup" -}}
```

Now we get that specific version of `rsc.io/pdf` that is known to be "old" Go code:


```
{{PrintBlock "go get pdf" -}}
```

Now check our code builds and runs:

```
{{PrintBlock "go build" -}}
```

Create a local copy of `rsc.io/pdf` and add a replace directive to use it:

```
{{PrintBlock "replace pdf" -}}
```

Now check our code still builds:

```
{{PrintBlock "go build fails" -}}
```

It doesn't; seems we need to mark that directory as a Go module with a `go.mod`:


```
{{PrintBlock "create pdf module" -}}
```

Now check our code builds and runs:

```
{{PrintBlock "go build check" -}}
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

Create ourselves a simple module that depends on an "old" Go package (`rsc.io/pdf` at `v0.1.1` is
"old", non-module code):


```
$ mkdir hello
$ cd hello
$ go mod init example.com/hello
go: creating new go.mod: module example.com/hello
$ cat <<EOD >hello.go
package main

import (
        "fmt"

        "rsc.io/pdf"
)

func main() {
        fmt.Println(pdf.Point{})
}
EOD
```

Now we get that specific version of `rsc.io/pdf` that is known to be "old" Go code:


```
$ go get rsc.io/pdf@v0.1.1
go: finding rsc.io/pdf v0.1.1
go: downloading rsc.io/pdf v0.1.1
$ cat go.mod
module example.com/hello

require rsc.io/pdf v0.1.1 // indirect
```

Now check our code builds and runs:

```
$ go build
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
$ go build
go: parsing pdf/go.mod: open /root/hello/pdf/go.mod: no such file or directory
go: error loading module requirements
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
$ go build
$ ./hello
{0 0}
```


### Version details

```
go version go1.11 linux/amd64
```

<!-- END -->
