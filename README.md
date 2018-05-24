### vgo by example

vgo by example is a series of work-along guides that look to help explain:

* how vgo works
* how to get things done with vgo

They are:

* work-in-progress
* pending review
* likely to move somewhere else

### Structure

A guide simply comprises a README.md and an accompanying bash script. For example, the vgo tour has been rewritten as a
vgo by example guide:

```
$ ls vgo_tour
README.md
script.sh
```

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

The corresponding README.md acts as a template for the guide itself, but crucially it can reference these blocks in
order to include the commands themselves and/or the output, e.g.:

  ```
  {{PrintBlock "go get vgo" -}}
  ```

Look at the raw [vgo tour README.md](https://raw.githubusercontent.com/myitcv/vgo-by-example/master/vgo_tour/README.md)
for more example of the guide template referencing the script.


### Testing scripts

To ensure reproducibility and isolation, scripts are run in a Docker container; the
[`golang`](https://hub.docker.com/_/golang/) container is used:

```
docker pull golang
```

The following two environment variables must be set:

```bash
GITHUB_USERNAME # your Github username
GITHUB_PAT      # a personal access token with public_repo scope
```

_[Create a new personal access token](https://github.com/settings/tokens/new)._

Ensure `egrunner` is installed (and on your PATH):

```
go install myitcv.io/vgo-by-example/cmd/egrunner
```

Now run in debug mode to see real-time output:

```
egrunner -debug vgo_tour/script.sh
```

### Regenerating a guide

First ensure `mdreplace` and `egrunner` are installed (and on your PATH):

```
go install myitcv.io/vgo-by-example/cmd/mdreplace myitcv.io/vgo-by-example/cmd/egrunner
```

Then re-run `mdreplace` on a guide template, e.g. for the vgo tour:

```
mdreplace -w ./vgo_tour/README.md
```

### TODO

* Make this a `vgo` project
* Move away from vendor of `mvdan.cc/sh` - currently vendoring to work around an issue with single statement printing.
