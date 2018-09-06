// mdreplace is a tool to help you keep your markdown README/documentation current.
//
// For more information see https://github.com/myitcv/x/blob/master/cmd/mdreplace/README.md
package main

import (
	"bytes"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"

	"myitcv.io/go-modules-by-example/cmd/mdreplace/internal/itemtype"
)

// take input from stdin or files (args)
// -w flag will write back to files (error if stdin)
// if no -w flag, write to stdout
//
// blocks take the form
//
// <!-- __XYZ: command args ...
// template block
// -->
// anything
// <!-- END -->
//
// No nesting supported; fatal if nested; fatal if block not terminated
// The "anything" part may contain code blocks; these code blocks effectively
// escape the end block; so the code block itself must be terminated, otherwise
// we will never find the end.

// ===========================
// Blocks:
//
// __TEMPLATE: cmd arg1 arg2 ...
// Takes the output from the command (string) and passes it to the
// template defined in the template block.
//
// Functions available for such a block include:
//
// * Lines(s string) []string
//
// __JSON: assumes the output from the command will be JSON; that is decoded into
// an interface{} and passed to the template defined in the template block.
// ===========================

var (
	fWrite = flag.Bool("w", false, "whether to write back to input files (cannot be used when reading from stdin)")
	fStrip = flag.Bool("strip", false, "whether to strip special comments from the file")
	fDebug = flag.Bool("debug", false, "whether to print debug information of not")

	fLong   = flag.Bool("long", false, "run LONG blocks")
	fOnline = flag.Bool("online", false, "run ONLINE blocks")
)

//go:generate pkgconcat -out gen_cliflag.go myitcv.io/_tmpls/cliflag

type stateFn func() stateFn

type item struct {
	typ itemtype.ItemType
	val string
}

func (i item) String() string {
	return fmt.Sprintf("{typ: %v, val: %q}", i.typ, i.val)
}

func main() {
	setupAndParseFlags(`Usage:

  mdreplace file1 file2 ...
  mdreplace

When called with no file arguments, mdreplace works with stdin
`)

	args := flag.Args()

	if *fWrite && len(args) == 0 {
		fatalf("Cannot use -w flag when reading from stdin\n\n%v", usage)
	}

	if len(args) == 0 {
		if err := run(os.Stdin, os.Stdout); err != nil {
			fatalf("%v\n", err)
		}
	} else {
		// ensure all the files exist first

		var files []*os.File

		for _, f := range args {
			abs, err := filepath.Abs(f)
			if err != nil {
				fatalf("failed to make absolute path %v: %v", f, err)
			}
			i, err := os.Open(abs)
			if err != nil {
				fatalf("failed to open %v: %v\n", abs, err)
			}

			files = append(files, i)
		}

		// if we have more than one file we fork another mdreplace
		// because we want to have a cwd of the file's dir when processing
		if len(files) > 1 {
			var wg sync.WaitGroup
			for i, f := range files {
				wg.Add(1)
				fn := f.Name()
				ofn := flag.Arg(i)

				go func() {
					defer func() {
						wg.Done()
					}()
					args := []string{os.Args[0]}
					if *fWrite {
						args = append(args, "-w")
					}
					if *fStrip {
						args = append(args, "-strip")
					}
					if *fDebug {
						args = append(args, "-debug")
					}
					if *fLong {
						args = append(args, "-long")
					}
					if *fOnline {
						args = append(args, "-online")
					}
					args = append(args, fn)

					cmd := exec.Command(args[0], args[1:]...)
					cmd.Dir = filepath.Dir(fn)

					fmt.Fprintf(os.Stderr, "Processing %v...\n", ofn)

					out, err := cmd.CombinedOutput()
					if err != nil {
						fatalf("cmd %v failed: %v\n%s", strings.Join(cmd.Args, " "), err, out)
					}

					fmt.Fprintf(os.Stderr, "Done processing %v\n", ofn)
				}()
			}

			wg.Wait()
			return
		}

		{
			f := files[0]
			dir := filepath.Dir(f.Name())
			if err := os.Chdir(dir); err != nil {
				fatalf("failed to chdir to %v: %v", dir, err)
			}
			var out io.Writer

			if *fWrite {
				out = new(bytes.Buffer)
			} else {
				out = os.Stdout
			}

			if err := run(f, out); err != nil {
				fatalf("%v\n", err)
			}

			// write back if -w specific
			if *fWrite {
				fn := f.Name()

				err := ioutil.WriteFile(f.Name(), out.(*bytes.Buffer).Bytes(), 0644)
				if err != nil {
					fatalf("failed to write to %v: %v\n", fn, err)
				}
			}
		}
	}
}

func run(r io.Reader, w io.Writer) error {
	_, items := lex(r)

	if err := process(items, w); err != nil {
		return err
	}

	return nil
}

func debugf(format string, args ...interface{}) {
	if debug || *fDebug {
		infof(format, args...)
	}
}
