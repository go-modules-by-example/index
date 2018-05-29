### `**This is a work-in-progress and pending review. Please do not link to this for now.**`

### vgo by example

vgo by example is a series of work-along guides that look to help explain how vgo works and how to get things done with vgo.

* [The vgo tour](https://github.com/myitcv/vgo-by-example/blob/master/001_vgo_tour/README.md) (rewritten as a vgo-by-example)
* [Using vgo with gopkg.in](https://github.com/myitcv/vgo-by-example/blob/master/002_using_gopkg_in/README.md)
* [Migrating Buffalo from dep to vgo](https://github.com/myitcv/vgo-by-example/blob/master/003_migrate_buffalo/README.md)
* ...

See the [Feedback and TODO wiki](https://github.com/myitcv/vgo-by-example/wiki/Feedback-TODO) for more up-to-date
commentary.

### Structure

A guide simply comprises a README.md and an accompanying bash script. The README is the human readable bit and the
script acts as a reproducible set of steps (that can be tested) for the guide. For example, the vgo tour has been
rewritten as a vgo by example guide:

<!-- __TEMPLATE: ls 001_vgo_tour
```
$ {{.Cmd}}
{{.Out -}}
```
-->
```
$ ls 001_vgo_tour
README.md
script.sh
```
<!-- END -->

script.sh contains, as its name suggests, the overall script for the guide. It includes a pre-amble that defines a
number of helper functions for testing the script, followed by the header:

```
# **START**
```

This marks the start of the script.

What follows are a number of optionally commented "blocks". For example, the following block is labelled `"go get vgo"`
and comprises all the contiguous lines that follow the special `# block:` comment:

```
# block: go get vgo
go get -u golang.org/x/vgo
assert "$? -eq 0" $LINENO
```

Assertions can be made within the script to ensure that everything is still "on track".

The corresponding README.md acts as a template for the guide itself, but crucially it can reference these blocks to
include the commands themselves and/or their output, e.g.:

    ```
    {{PrintBlock "go get vgo" -}}
    ```

Look at the raw [vgo tour README.md](https://raw.githubusercontent.com/myitcv/vgo-by-example/master/001_vgo_tour/README.md)
and [corresponding script](https://github.com/myitcv/vgo-by-example/blob/master/001_vgo_tour/script.sh) for more examples.

### Testing scripts

To ensure reproducibility and isolation, scripts are run in a Docker container; the
[`golang`](https://hub.docker.com/_/golang/) container is used:

<!-- __TEMPLATE: docker pull golang # LONG ONLINE
```
{{.Cmd}}
```
-->
```
docker pull golang
```
<!-- END -->

The following two environment variables must be set:

```bash
GITHUB_USERNAME # your Github username
GITHUB_PAT      # a personal access token with public_repo scope
```

_[Create a new personal access token](https://github.com/settings/tokens/new)._

Ensure `egrunner` is installed (and on your PATH):

<!-- __TEMPLATE: vgo install myitcv.io/vgo-by-example/cmd/egrunner
```
{{.Cmd}}
```
-->
```
vgo install myitcv.io/vgo-by-example/cmd/egrunner
```
<!-- END -->

Now run in debug mode to see real-time output:

<!-- __TEMPLATE: egrunner -debug ./001_vgo_tour/script.sh # LONG ONLINE
```
{{.Cmd}}
```
-->
```
egrunner -debug ./001_vgo_tour/script.sh
```
<!-- END -->

### Regenerating a guide

First ensure `mdreplace` and `egrunner` are installed (and on your PATH):

<!-- __TEMPLATE: vgo install myitcv.io/vgo-by-example/cmd/egrunner myitcv.io/vgo-by-example/cmd/mdreplace
```
{{.Cmd}}
```
-->
```
vgo install myitcv.io/vgo-by-example/cmd/egrunner myitcv.io/vgo-by-example/cmd/mdreplace
```
<!-- END -->

Then re-run `mdreplace` on a guide template, e.g. for the vgo tour:

<!-- __TEMPLATE: mdreplace -w ./001_vgo_tour/README.md # LONG ONLINE
```
{{.Cmd}}
```
-->
```
mdreplace -w ./001_vgo_tour/README.md
```
<!-- END -->

### Caveats

This project is:

* work-in-progress
* pending review
* likely to move somewhere else
