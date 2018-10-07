<!-- __JSON: egrunner script.sh # LONG ONLINE

## Using `github.com/rogpeppe/gohack`

[`gohack`](https://github.com/rogpeppe/gohack) is a tool that makes it easy to make temporary edits to your Go modules dependencies. This example shows how to
use it.

### Walkthrough

Install `gohack`:

```
{{PrintBlock "install gohack" -}}
```

Ceate an example module:

```
{{PrintBlock "setup" -}}
```

Depend on some module:

```
{{PrintBlockOut "simple example" -}}
```

In this case, we will use a specific version of our dependency:

```
{{PrintBlock "use a specific version of quote" -}}
```

Run the example:

```
{{PrintBlock "run example" -}}
```

Now let's assume we want to tweak the `rsc.io/quote` package, in particular we want to tweak the `Hello` function we are
using. We will use `gohack` to do this.


"Hack" on `rsc.io/quote`:

```
{{PrintBlock "gohack quote" -}}
```

Verify our module is using the local "hack" copy:

```
{{PrintBlock "see replace" -}}
```

`gohack` puts "hacks" in `$HOME/$module`; we make our changes there:


```
{{PrintBlock "make edit" -}}
```

Rerun our example:

```
{{PrintBlock "rerun" -}}
```

Revert to the original `rsc.io/quote`:

```
{{PrintBlock "undo" -}}
```

### Version details

```
{{PrintBlockOut "version details" -}}
```

-->

## Using `github.com/rogpeppe/gohack`

[`gohack`](https://github.com/rogpeppe/gohack) is a tool that makes it easy to make temporary edits to your Go modules dependencies. This example shows how to
use it.

### Walkthrough

Install `gohack`:

```
$ GO111MODULE=off go get github.com/rogpeppe/gohack
$ gohack help
The gohack command checks out Go module dependencies
into a directory where they can be edited, and adjusts
the go.mod file appropriately.

Usage:

	gohack <command> [arguments]

The commands are:

	get         start hacking a module
	undo        stop hacking a module
	status      print the current hack status of a module

Use "gohack help <command>" for more information about a command.
```

Ceate an example module:

```
$ mkdir /tmp/using-gohack
$ cd /tmp/using-gohack
$ go mod init example.com/blah
go: creating new go.mod: module example.com/blah
```

Depend on some module:

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

In this case, we will use a specific version of our dependency:

```
$ go get rsc.io/quote@v1.5.1
go: finding rsc.io/quote v1.5.1
go: finding rsc.io/sampler v1.3.0
go: finding golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
go: downloading rsc.io/quote v1.5.1
go: downloading rsc.io/sampler v1.3.0
go: downloading golang.org/x/text v0.0.0-20170915032832-14c0d48ead0c
```

Run the example:

```
$ go run .
Hello, world.
```

Now let's assume we want to tweak the `rsc.io/quote` package, in particular we want to tweak the `Hello` function we are
using. We will use `gohack` to do this.


"Hack" on `rsc.io/quote`:

```
$ gohack get rsc.io/quote
rsc.io/quote => /root/gohack/rsc.io/quote
```

Verify our module is using the local "hack" copy:

```
$ go mod edit -json
{
	"Module": {
		"Path": "example.com/blah"
	},
	"Require": [
		{
			"Path": "rsc.io/quote",
			"Version": "v1.5.1"
		}
	],
	"Exclude": null,
	"Replace": [
		{
			"Old": {
				"Path": "rsc.io/quote"
			},
			"New": {
				"Path": "/root/gohack/rsc.io/quote"
			}
		}
	]
}
```

`gohack` puts "hacks" in `$HOME/$module`; we make our changes there:


```
$ cd $HOME/gohack/rsc.io/quote
$ cat <<EOD >quote.go
package quote

func Hello() string {
	return "My hello"
}
EOD
```

Rerun our example:

```
$ cd /tmp/using-gohack
$ go run .
My hello
```

Revert to the original `rsc.io/quote`:

```
$ gohack undo rsc.io/quote
dropped rsc.io/quote
$ go run .
Hello, world.
```

### Version details

```
go version go1.11.1 linux/amd64
gohack commit 9c9664a5b5fe88c58959a302141c6a12dd40421e
```

<!-- END -->
