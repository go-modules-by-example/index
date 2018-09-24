<!-- __JSON: egrunner script.sh # LONG ONLINE

## `** REVIEW REQUIRED **`

This guide is a WIP.

----

Use Go 1.10.3 which includes [minimal module support for go modules
transition](https://github.com/golang/go/issues/25139):

```
{{PrintBlock "use Go 1.10.3" -}}
```

Create a simple module that is a major version v2:


```
{{PrintBlock "create go module v2" -}}
```

Now create a `main` go module to use our v2 module:


```
{{PrintBlock "Go module use v2 module" -}}
```

Now create a GOPATH-based `main` old-Go (non-module) package that uses our v2 module:


```
{{PrintBlock "GOPATH use v2 module" -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## `** REVIEW REQUIRED **`

This guide is a WIP.

----

Use Go 1.10.3 which includes [minimal module support for go modules
transition](https://github.com/golang/go/issues/25139):

```
$ cd /tmp
$ curl -s https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz | tar -zx
$ PATH=/tmp/go/bin:$PATH which go
/tmp/go/bin/go
$ PATH=/tmp/go/bin:$PATH go version
go version go1.10.3 linux/amd64
```

Create a simple module that is a major version v2:


```
$ cd $HOME
$ mkdir hello
$ cd hello
$ cat <<EOD >hello.go
package example

import "github.com/myitcv/go-modules-by-example-v2-module/v2/goodbye"

const Name = goodbye.Name
EOD
$ cat <<EOD >go.mod
module github.com/myitcv/go-modules-by-example-v2-module/v2
EOD
$ mkdir goodbye
$ cat <<EOD >goodbye/goodbye.go
package goodbye

const Name = "Goodbye"
EOD
$ go test ./...
?   	github.com/myitcv/go-modules-by-example-v2-module/v2	[no test files]
?   	github.com/myitcv/go-modules-by-example-v2-module/v2/goodbye	[no test files]
$ git init
Initialized empty Git repository in /root/hello/.git/
$ git add -A
$ git commit -m 'Initial commit'
[master (root-commit) d14be8b] Initial commit
 3 files changed, 9 insertions(+)
 create mode 100644 go.mod
 create mode 100644 goodbye/goodbye.go
 create mode 100644 hello.go
$ git remote add origin https://github.com/myitcv/go-modules-by-example-v2-module
$ git push origin master
remote: 
remote: Create a pull request for 'master' on GitHub by visiting:        
remote:      https://github.com/myitcv/go-modules-by-example-v2-module/pull/new/master        
remote: 
To https://github.com/myitcv/go-modules-by-example-v2-module
 * [new branch]      master -> master
$ git tag v2.0.0
$ git push origin v2.0.0
To https://github.com/myitcv/go-modules-by-example-v2-module
 * [new tag]         v2.0.0 -> v2.0.0
```

Now create a `main` go module to use our v2 module:


```
$ cd $HOME
$ mkdir usehello
$ cd usehello
$ cat <<EOD >main.go
package main

import "fmt"
import "github.com/myitcv/go-modules-by-example-v2-module/v2"

func main() {
	fmt.Println(example.Name)
}
EOD
$ go mod init example.com/usehello
go: creating new go.mod: module example.com/usehello
$ go build
go: finding github.com/myitcv/go-modules-by-example-v2-module/v2 v2.0.0
go: downloading github.com/myitcv/go-modules-by-example-v2-module/v2 v2.0.0
$ ./usehello
Goodbye
```

Now create a GOPATH-based `main` old-Go (non-module) package that uses our v2 module:


```
$ cd $GOPATH
$ mkdir -p src/example.com/hello
$ cd src/example.com/hello
$ cat <<EOD >main.go
package main

import "fmt"
import "github.com/myitcv/go-modules-by-example-v2-module"

func main() {
	fmt.Println(example.Name)
}
EOD
$ PATH=/tmp/go/bin:$PATH go get github.com/myitcv/go-modules-by-example-v2-module
$ PATH=/tmp/go/bin:$PATH go build
$ ./hello
Goodbye
```

### Version details

```
go version go1.11 linux/amd64
```

<!-- END -->
