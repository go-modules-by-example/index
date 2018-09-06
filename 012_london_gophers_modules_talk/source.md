<!-- __JSON: egrunner script.sh # LONG ONLINE

What are Go modules and how do I use them?
15 Aug 2018

Paul Jolly
modelogiq
paul@myitcv.io
https://myitcv.io
@_myitcv

* Today we will

- Look at why we need package management in Go
- Introduce Go modules
- Work through a number of examples
- See how you can get started using modules
- Contribute back to the Go project in the process

* Why do we need package management in Go?

* t0: we start to write program P

.image images/t0.png

* t1: we add a dependency on D

.image images/t1.png

: Downloads and installs current latest version of D; 1.0

* t2: we add a dependency on C

.image images/t2.png

: Some time later we add a dependency on C; latest version is 1.8
: C requires D 1.4, but go get spots we already have package D
: C is broken, and in this case P is broken
: D is too old

* t3: we update C (and its dependencies)

.image images/t3.png

: go get -u updates C and its dependencies
: unfortunately author of D just released 1.6
: Turns out D also breaks C... and by extension P
: Now D is too new
: So sometimes go get fails because it leaves us in a situation where D is too old, sometimes too new
: What we need is the ability to build P with exactly the version that the author of C used
: But go get has not awareness of package versions at all

* History

- Various tools/approaches to help specify version requirements
- GOPATH, goven, godeps, godep, gopkg.in, glide, gb, govendor, vendor dir, dep
- All approaches vary somewhat
- Cannot create other version-aware tools

* Introducing Go modules

* Go 1.11 introduces Go modules

- A module is a collection of related Go packages
- Modules are the unit of source code interchange and versioning
- The go command has direct support for working with modules
- Modules replace the old GOPATH-based approach to specifying which source files are used in a given build

    go help modules

* The principles of versioning in Go

*Compatibility*

Import compatibility rule - if and old package and a new package have the same import path, the new package must be backwards-compatible with the old package

*Repeatability*

The result of a build of a given version of a package should not change over time

*Cooperation*

We must all work together to maintain the Go package ecosystem. Tools cannot work around a lack of cooperation.

* Semantic Import Versioning

.image images/semver.png 400 _

.caption See https://semver.org/ and https://research.swtch.com/vgo-import

* Worked Example 1: creating a module

* Example 1: creating a module

{{PrintBlock "simple example part 1" | indent}}

* Example 1: adding a dependency

{{PrintBlock "simple example part 2" | indent}}

* Example 1: examine dependencies

{{PrintBlock "simple example part 3" | indent}}

: The go.mod file lists a minimal set of requirements, omitting those implied by the ones already listed
: Even if rsc.io/quote v1.5.3 or v1.6.0 is released tomorrow, builds in this directory will keep using v1.5.2 until an explicit upgrade (see below).

* Example 1: rebuild

{{PrintBlock "simple example part 4" | indent}}

: why our simple “hello world” program uses golang.org/x/text. It turns out that rsc.io/quote depends on rsc.io/sampler, which in turn uses golang.org/x/text for language matching

* Example 1: upgrading modules

{{PrintBlock "simple example part 5" | indent}}

* Example 1: testing

{{PrintBlock "simple example part 6" | lineEllipsis 10 | indent}}

* Example 1: module packages

{{PrintBlock "simple example part 7" | indent}}

* Example 1: upgrade all modules

{{PrintBlock "simple example part 8" | indent}}

* Example 1: retest

{{PrintBlock "simple example part 9" | lineEllipsis 10 | indent}}

* Example 1: check behaviour

{{PrintBlock "simple example part 10" | indent}}

* Example 1: downgrading

{{PrintBlock "simple example part 11" | indent}}

* Example 1: retest post downgrade

{{PrintBlock "simple example part 12" | lineEllipsis 10 | indent}}

* Example 1: fork quote

{{PrintBlock "simple example part 13" | indent}}

Edit `quote.go`.

* Example 1: use local changes

{{PrintBlock "simple example part 14" | indent}}

* Example 1: push our local changes to remote fork

{{PrintBlock "simple example part 15" | indent}}

* Example 1: use remote version

{{PrintBlock "simple example part 16" | indent}}

* Worked Example 2: converting an existing project

* Example 2: converting an existing project

{{PrintBlock "convert part 1" | lineEllipsis 15 | indent}}

* Much more

- Publishing modules
- Proxy support for published modules ([[https://github.com/gomods/athens]])
- Tooling built atop go modules ([[https://github.com/rogpeppe/gohack]])
- Full support for custom import paths
- Go submodules natively supported (mono repos)

* More subcommands

  Usage:

        go mod <command> [arguments]

  The commands are:

        download    download modules to local cache
        edit        edit go.mod from tools or scripts
        fix         make go.mod semantically consistent
        graph       print module requirement graph
        init        initialize new module in current directory
        tidy        add missing and remove unused modules
        vendor      make vendored copy of dependencies
        verify      verify dependencies have expected content
        why         explain why packages or modules are needed


* Great: how/where do I get started?

* Use Go 1.11rc1

- Two days ago Go 1.11rc1 was released
- Download or install
- Has module support
- Work outside GOPATH or set GO111MODULE=on inside GOPATH

    go get http://golang.org/dl/go1.11rc1
    go1.11rc1 download
    go1.11rc1 help modules

* Try out modules

- Start new projects using Go modules
- Convert existing projects
- Ask questions: golang-nuts, Gophers Slack, Stack Overflow... ([[https://github.com/golang/go/wiki/Questions]])
- Report Github issues for bugs or (a lack of) documentation ([[https://github.com/golang/go/issues/new]])
- Create experience reports ([[https://github.com/golang/go/wiki/ExperienceReports]])

: Check existing issues; look at existing issues for best practice

* Success stories

.image images/roger.png 200 _
.image images/filippo.png 300 _

* FAQ

- should we replace `dep` with modules?
- should we wait to start using modules?
- should we still be vendoring dependencies?
- how can we convert a `v>=2` project to a Go module without breaking import paths?

: stability and support for older Go releases, vs not needing to use a third party tool and being able to drop GOPATH and vendor, etc
: unless people want to run rc1 in CI/CD, I presume most will want to wait for the final release
: can be good to support older versions of Go, and as a temporary solution to the lack of a module proxy community
: the good old question; perhaps not as popular as the others, though

* Credits

- Russ Cox and Bryan Mills for their work in making Go modules happen
- Numerous people in the Go community, both inside and out of Google, who have helped to get modules to where they are today
- Daniel Martí, Roger Peppe and Axel Wagner for sharing thoughts/giving feedback on these slides and Go modules topics more broadly

* Links

- `cmd/go` documentation ([[https://tip.golang.org/cmd/go]])
- Modules wiki ([[https://github.com/golang/go/wiki/Modules]])
- Russ Cox's GopherCon Singapore Keynote ([[https://www.youtube.com/watch?v=F8nrpe0XWRg]])
- Russ Cox's original `vgo` series ([[https://research.swtch.com/vgo]])


-->

<!-- END -->
