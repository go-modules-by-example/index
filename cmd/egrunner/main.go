package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"strings"

	"mvdan.cc/sh/syntax"
)

var (
	debug  = false
	fDebug = flag.Bool("debug", false, "print debugging information")
)

const (
	scriptName      = "script.sh"
	blockPrefix     = "block:"
	outputSeparator = "============================================="
	commentStart    = "**START**"

	commgithubcli = "githubcli"
)

type block string

func (b *block) String() string {
	if b == nil {
		return "nil"
	}

	return string(*b)
}

func main() {
	flag.Parse()

	toRun := new(bytes.Buffer)
	toRun.WriteString(`#!/usr/bin/env bash
set -u

assert()
{
  E_PARAM_ERR=98
  E_ASSERT_FAILED=99

  if [ -z "$2" ]
  then
    exit $E_PARAM_ERR
  fi

  lineno=$2

  if [ ! $1 ]
  then
    echo "Assertion failed:  \"$1\""
    echo "File \"$0\", line $lineno"
    exit $E_ASSERT_FAILED
  fi
}

`)

	ghcli, err := exec.LookPath(commgithubcli)
	if err != nil {
		errorf("failed to find %v in PATH", commgithubcli)
	}

	if len(flag.Args()) != 1 {
		errorf("expected a single argument script file to run")
	}

	fn := flag.Arg(0)

	fi, err := os.Open(fn)
	if err != nil {
		errorf("failed to open %v: %v", fn, err)
	}

	f, err := syntax.NewParser(syntax.KeepComments).Parse(fi, fn)
	if err != nil {
		errorf("failed to parse %v: %v", fn, err)
	}

	var last *syntax.Pos
	var b *block

	// blocks is a mapping from statement index to *block this allows us to take
	// the output from each statement and not only assign it to the
	// corresponding index but also add to the block slice too (if the block is
	// defined)
	seenBlocks := make(map[block]bool)

	p := syntax.NewPrinter()

	stmtString := func(s *syntax.Stmt) string {
		// temporarily "blank" the comments associated with the stmt
		cs := s.Comments
		s.Comments = nil
		var b bytes.Buffer
		p.Print(&b, s)
		s.Comments = cs
		return b.String()
	}

	type cmdOutput struct {
		Cmd string
		Out string
	}

	var stmts []*cmdOutput
	blocks := make(map[block][]*cmdOutput)

	pendingSep := false

	// find the # START comment
	var start *syntax.Comment

	for _, s := range f.Stmts {
		if start == nil {
			for _, c := range s.Comments {
				if s.Pos().After(c.End()) {
					if strings.TrimSpace(c.Text) == commentStart {
						start = &c
					}
				}
			}
		}
		if start == nil || start.Pos().After(s.Pos()) {
			continue
		}
		setBlock := false
		for _, c := range s.Comments {
			if s.Pos().After(c.End()) && s.Pos().Line()-1 == c.End().Line() {
				l := strings.TrimSpace(c.Text)
				if strings.HasPrefix(l, blockPrefix) {
					v := block(strings.TrimSpace(strings.TrimPrefix(l, blockPrefix)))
					if seenBlocks[v] {
						errorf("block %q used multiple times", v)
					}
					seenBlocks[v] = true
					b = &v
					setBlock = true
				}
			}
		}
		if !setBlock {
			if last != nil && last.Line()+1 != s.Pos().Line() {
				// end of contiguous block
				b = nil
			}
		}
		isAssert := false
		if ce, ok := s.Cmd.(*syntax.CallExpr); ok {
			if ce.Args != nil && ce.Args[0].Parts != nil {
				if li, ok := ce.Args[0].Parts[0].(*syntax.Lit); ok {
					if li.Value == "assert" {
						isAssert = true
					}
				}
			}
		}
		if isAssert {
			// TODO improve this by actually inspecting the second argument
			// to assert
			l := stmtString(s)
			l = strings.Replace(l, "$LINENO", fmt.Sprintf("%v", s.Pos().Line()), -1)
			fmt.Fprintf(toRun, "%v\n", l)
		} else {
			co := &cmdOutput{
				Cmd: stmtString(s),
			}

			if pendingSep {
				fmt.Fprintf(toRun, "echo \"%v\"\n", outputSeparator)
			}
			stmts = append(stmts, co)
			if debug || *fDebug {
				fmt.Fprintf(toRun, "cat <<THISWILLNEVERMATCH\n%v\nTHISWILLNEVERMATCH\n", stmtString(s))
			}
			fmt.Fprintf(toRun, "%v\n", stmtString(s))
			pendingSep = true

			if b != nil {
				blocks[*b] = append(blocks[*b], co)
			}
		}

		// now calculate the last line of this statement, including heredocs etc

		// TODO this might need to be better
		end := s.End()
		for _, r := range s.Redirs {
			if r.End().After(end) {
				end = r.End()
			}
			if r.Hdoc != nil {
				if r.Hdoc.End().After(end) {
					end = r.Hdoc.End()
				}
			}
		}
		last = &end
	}

	if pendingSep {
		fmt.Fprintf(toRun, "echo \"%v\"\n", outputSeparator)
	}

	// docker requires the file/directory we are mapping to be within our
	// home directory because of "security"
	tf, err := ioutil.TempFile(os.Getenv("HOME"), ".vgo_by_example")
	if err != nil {
		errorf("failed to create temp file: %v", err)
	}

	tfn := tf.Name()

	defer func() {
		os.Remove(tf.Name())
	}()

	if err := ioutil.WriteFile(tfn, toRun.Bytes(), 0644); err != nil {
		errorf("failed to write to temp file %v: %v", tfn, err)
	}

	user := os.Getenv("GITHUB_USERNAME")
	pat := os.Getenv("GITHUB_PAT")

	cmd := exec.Command("docker", "run", "--rm", "-v", fmt.Sprintf("%v:/go/bin/%v", ghcli, commgithubcli), "-v", fmt.Sprintf("%v:/%v", tfn, scriptName), "-e", "GITHUB_PAT="+pat, "-e", "GITHUB_USERNAME="+user, "--entrypoint", "bash", "golang", fmt.Sprintf("/%v", scriptName))
	debugf("now running %v via %v\n", tfn, strings.Join(cmd.Args, " "))

	if debug || *fDebug {
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			errorf("failed to run %v: %v", strings.Join(cmd.Args, " "), err)
		}
		return
	}
	out, err := cmd.CombinedOutput()
	if err != nil {
		errorf("failed to run %v: %v\n%s", strings.Join(cmd.Args, " "), err, out)
	}

	var lines []string
	scanner := bufio.NewScanner(strings.NewReader(string(out)))
	cur := new(strings.Builder)
	for scanner.Scan() {
		l := scanner.Text()
		if l == outputSeparator {
			lines = append(lines, cur.String())
			cur = new(strings.Builder)
			continue
		}
		cur.WriteString(l)
		cur.WriteString("\n")
	}
	if err := scanner.Err(); err != nil {
		errorf("error scanning cmd output: %v", err)
	}

	if len(lines) != len(stmts) {
		errorf("had %v statements but %v lines of output", len(stmts), len(lines))
	}

	for i := range stmts {
		stmts[i].Out = lines[i]
	}

	tmpl := struct {
		Stmts  []*cmdOutput
		Blocks map[block][]*cmdOutput
	}{
		Stmts:  stmts,
		Blocks: blocks,
	}

	byts, err := json.MarshalIndent(tmpl, "", "  ")
	if err != nil {
		errorf("error marshaling JSON: %v", err)
	}

	fmt.Printf("%s\n", byts)
}

func errorf(format string, args ...interface{}) {
	if debug || *fDebug {
		panic(fmt.Errorf(format, args...))
	}
	fmt.Fprintf(os.Stderr, format+"\n", args...)
	os.Exit(1)
}

func debugf(format string, args ...interface{}) {
	if debug || *fDebug {
		fmt.Printf(format, args...)
	}
}
