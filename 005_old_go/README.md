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
$ PATH=/tmp/go/bin:$PATH which go
/tmp/go/bin/go
$ PATH=/tmp/go/bin:$PATH go version
go version go1.10.3 linux/amd64
```

Get vgo:


```
```

Create a simple module that is a major version v2:


```
```

Now create a `main` vgo module to use our v2 module:


```
```

Now create a GOPATH-based `main` old-Go (non-module) package that uses our v2 module:


```
```

### Version details

```
go version go1.11 linux/amd64
```

<!-- END -->
