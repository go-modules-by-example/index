package main

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"sort"
	"strconv"
	"strings"
	"text/template"

	"myitcv.io/vgo-by-example/cmd/mdreplace/internal/itemtype"
)

func (p *processor) processCommonBlock(prefix string, conv func(string, []byte) cmdOut) procFn {
	// consume the (quoted) arguments

	var orig []string
	var args []string
	var options []string

	sortInvariant := false
	execute := true

Args:
	for {
		i := p.next()

		t := i.val

		switch i.typ {
		case itemtype.ItemArgComment:
			options = []string{}
			// consume any options
			for {
				i := p.next()
				if i.typ != itemtype.ItemOption {
					break Args
				}
				switch i.val {
				case optionLong:
					execute = execute && *fLong
				case optionOnline:
					execute = execute && *fOnline
				case optionSortInvariant:
					sortInvariant = true
				default:
					p.errorf("unknown option %v", i.val)
				}
				options = append(options, i.val)
			}

		case itemtype.ItemArg:
		case itemtype.ItemQuoteArg:
			v, err := strconv.Unquote(i.val)
			if err != nil {
				p.errorf("failed to unquote %q: %v", i.val, err)
			}
			t = v
		default:
			break Args
		}

		orig = append(orig, i.val)

		// this should succeed because we previously unquoted it during lexing

		t = os.Expand(t, func(s string) string {
			debugf("Expand %q\n", s)
			if s == "DOLLAR" {
				return "$"
			}

			return os.Getenv(s)
		})

		args = append(args, t)
	}

	debugf("Will run with args \"%v\"\n", strings.Join(args, "\", \""))

	origCmdStr := strings.Join(orig, " ")

	if len(args) == 0 {
		p.errorf("didn't see any args")
	}

	// at this point we can accept a run of text or code fence blocks
	// because both are valid as block args; we simple concat them
	// together
	tmpl := new(strings.Builder)

	for p.curr.typ != itemtype.ItemCommEnd {
		switch p.curr.typ {
		case itemtype.ItemCodeFence, itemtype.ItemCode, itemtype.ItemText:
			tmpl.WriteString(p.curr.val)
		default:
			p.errorf("didn't expect to see a %v", p.curr.typ)
		}
		p.next()
	}

	// consume the commEnd
	p.next()

	// print the header now in case we are not executing
	if !*fStrip {
		p.printf(prefix+" %v", origCmdStr)

		if len(options) > 0 {
			p.printf(" %v %v", string(optionStart), strings.Join(options, " "))
		}

		p.printf("\n%v"+commEnd+"\n", tmpl)
	}

	prevBuf := new(bytes.Buffer)

	// again we can expect text or code fence blocks here; we are just
	// going to ignore them.
	for p.curr.typ != itemtype.ItemBlockEnd {
		switch p.curr.typ {
		case itemtype.ItemCodeFence, itemtype.ItemCode, itemtype.ItemText:
			if !execute {
				p.print(p.curr.val)
			} else {
				if _, err := prevBuf.WriteString(p.curr.val); err != nil {
					p.errorf("failed to write to prevBuf: %v", err)
				}
			}
		default:
			p.errorf("didn't expect to see a %v", p.curr.typ)
		}
		p.next()
	}

	// consume the block end
	p.next()

	output := prevBuf

	if execute {
		// ok now process the command, parse the template and write everything
		cmd := exec.Command(args[0], args[1:]...)
		out, err := cmd.CombinedOutput()
		if err != nil {
			p.errorf("failed to run command %q: %v\n%v", origCmdStr, err, string(out))
		}

		i := conv(strings.Join(cmd.Args, " "), out)

		// TODO gross hack for now
		tmplFuncMap["PrintCmd"] = func(k string) interface{} {
			m := i.Out.(map[string]interface{})
			if bs, ok := m["Blocks"]; ok {
				bsm := bs.(map[string]interface{})
				if v, ok := bsm[k]; ok {
					vs := v.([]interface{})
					if len(vs) == 1 {
						jv := vs[0].(map[string]interface{})
						return jv["Cmd"]
					}
				}
			}

			return nil
		}

		tmplFuncMap["PrintOut"] = func(k string) interface{} {
			m := i.Out.(map[string]interface{})
			if bs, ok := m["Blocks"]; ok {
				bsm := bs.(map[string]interface{})
				if v, ok := bsm[k]; ok {
					vs := v.([]interface{})
					if len(vs) == 1 {
						jv := vs[0].(map[string]interface{})
						return jv["Out"]
					}
				}
			}

			return nil
		}

		tmplFuncMap["PrintBlock"] = func(k string) string {
			m := i.Out.(map[string]interface{})
			if bs, ok := m["Blocks"]; ok {
				bsm := bs.(map[string]interface{})
				if v, ok := bsm[k]; ok {
					vs := v.([]interface{})
					res := new(strings.Builder)
					for _, j := range vs {
						jj := j.(map[string]interface{})
						fmt.Fprintf(res, "$ %v\n", jj["Cmd"])
						if o := jj["Out"]; o != "" {
							// new line will be part of output
							fmt.Fprintf(res, "%v", o)
						}
					}
					return res.String()
				}
			}

			return ""
		}

		tmplFuncMap["PrintBlockOut"] = func(k string) string {
			m := i.Out.(map[string]interface{})
			if bs, ok := m["Blocks"]; ok {
				bsm := bs.(map[string]interface{})
				if v, ok := bsm[k]; ok {
					vs := v.([]interface{})
					res := new(strings.Builder)
					for _, j := range vs {
						jj := j.(map[string]interface{})
						fmt.Fprintf(res, "%v", jj["Out"])
					}
					return res.String()
				}
			}

			return ""
		}

		t, err := template.New("").Funcs(tmplFuncMap).Parse(tmpl.String())
		if err != nil {
			p.errorf("failed to parse template %q: %e", tmpl, err)
		}

		newBuf := new(bytes.Buffer)

		if err := t.Execute(newBuf, i); err != nil {
			p.errorf("failed to execute template %q with input %q: %v", tmpl, i, err)
		}

		newOutput := func() bool {
			// line-wise sort prevBuf and newBuf
			p := prevBuf.String()
			n := newBuf.String()

			ps := strings.Split(p, "\n")
			ns := strings.Split(n, "\n")

			if len(ps) != len(ns) {
				return true
			}

			sort.Strings(ps)
			sort.Strings(ns)

			for i := range ps {
				if ps[i] != ns[i] {
					return true
				}
			}

			return false
		}

		// if sortInvariant then we want to only write the output if it has changed
		if !sortInvariant || newOutput() {
			output = newBuf
		}
	}

	p.print(output.String())

	if !*fStrip {
		p.println(blockEnd)
	}

	return p.processText
}
