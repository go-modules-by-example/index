<!-- __JSON: egrunner script.sh # LONG ONLINE

Use Go 1.10.3 which includes [minimal module support for vgo
transition](https://github.com/golang/go/issues/25139):

```
{{PrintBlock "use Go 1.10.3" -}}
```

Get vgo:


```
{{PrintBlock "go get vgo" -}}
```

Create a simple module that is a major version v2:


```
{{PrintBlock "create vgo module v2" -}}
```

Now create a `main` vgo module to use our v2 module:


```
{{PrintBlock "vgo use v2 module" -}}
```

Now create a GOPATH-based `main` old-Go (non-module) package that uses our v2 module:


```
{{PrintBlock "go use v2 module" -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

Use Go 1.10.3 which includes [minimal module support for vgo
transition](https://github.com/golang/go/issues/25139):

```
$ cd /tmp
$ curl -s https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz | tar -zx
$ export PATH=/tmp/go/bin:$PATH
$ which go
/tmp/go/bin/go
$ go version
go version go1.10.3 linux/amd64
```

Get vgo:


```
$ go get -u golang.org/x/vgo
```

Create a simple module that is a major version v2:


```
$ cd $HOME
$ mkdir hello
$ cd hello
$ cat <<EOD >hello.go
package example

import "github.com/myitcv/vgo-by-example-v2-module/v2/goodbye"

const Name = goodbye.Name
EOD
$ cat <<EOD >go.mod
module github.com/myitcv/vgo-by-example-v2-module/v2
EOD
$ mkdir goodbye
$ cat <<EOD >goodbye/goodbye.go
package goodbye

const Name = "Goodbye"
EOD
$ vgo test ./...
?   	github.com/myitcv/vgo-by-example-v2-module/v2	0.004s [no test files]
?   	github.com/myitcv/vgo-by-example-v2-module/v2/goodbye	0.004s [no test files]
$ git init
Initialized empty Git repository in /root/hello/.git/
$ git add -A
$ git commit -m 'Initial commit'
[master (root-commit) d0d577f] Initial commit
 3 files changed, 9 insertions(+)
 create mode 100644 go.mod
 create mode 100644 goodbye/goodbye.go
 create mode 100644 hello.go
$ git remote add origin https://github.com/myitcv/vgo-by-example-v2-module
$ git push origin master
To https://github.com/myitcv/vgo-by-example-v2-module
 * [new branch]      master -> master
$ git tag v2.0.0
$ git push origin v2.0.0
To https://github.com/myitcv/vgo-by-example-v2-module
 * [new tag]         v2.0.0 -> v2.0.0
```

Now create a `main` vgo module to use our v2 module:


```
$ cd $HOME
$ mkdir usehello
$ cd usehello
$ cat <<EOD >main.go
package main // import "example.com/usehello"

import "fmt"
import "github.com/myitcv/vgo-by-example-v2-module/v2"

func main() {
	fmt.Println(example.Name)
}
EOD
$ echo >go.mod
$ vgo build
vgo: resolving import "github.com/myitcv/vgo-by-example-v2-module/v2"
vgo: finding github.com/myitcv/vgo-by-example-v2-module/v2 (latest)
vgo: adding github.com/myitcv/vgo-by-example-v2-module/v2 v2.0.0
vgo: finding github.com/myitcv/vgo-by-example-v2-module/v2 v2.0.0
vgo: downloading github.com/myitcv/vgo-by-example-v2-module/v2 v2.0.0
$ ./usehello
Goodbye
```

Now create a GOPATH-based `main` old-Go (non-module) package that uses our v2 module:


```
$ cd $GOPATH
$ mkdir -p src/example.com/hello
$ cd src/example.com/hello
$ cat <<EOD >main.go
package main // import "example.com/hello"

import "fmt"
import "github.com/myitcv/vgo-by-example-v2-module"

func main() {
	fmt.Println(example.Name)
}
EOD
$ go get github.com/myitcv/vgo-by-example-v2-module
$ go build
$ ./hello
Goodbye
```

### Version details

```
cannot determine module root; please create a go.mod file there
vgo commit: 22e23900224f03be49670113d5781e4d89090f45
```

<!-- END -->
