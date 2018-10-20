<!-- __JSON: egrunner -df -v=/tmp:/tmp script.sh # LONG ONLINE

## Simple example

This is a simple example

```
{{PrintBlock "script" -}}
```
-->

## Simple example

This is a simple example

```
$ cd $HOME
$ mkdir simple
$ cd simple
$ go mod init example.com/simple
go: creating new go.mod: module example.com/simple
$ go list -m
example.com/simple
```
<!-- END -->
