package main

import (
	"bufio"
	"fmt"
	"path/filepath"
	"strings"
	"text/template"
)

var tmplFuncMap = template.FuncMap{
	"filepathBase": filepath.Base,
	"between": func(start, end, text string) string {
		sb := new(strings.Builder)
		lines := strings.Split(text, "\n")
		print := false
		for _, line := range lines {
			if print {
				if line == end {
					print = false
					continue
				}
				sb.WriteString(line + "\n")
				continue
			}

			if line == start {
				print = true
			}
		}
		return sb.String()
	},
	"fromHere": func(h string, s string) string {
		lines := strings.Split(s, "\n")
		i := len(lines) - 1
		for ; i >= 0; i-- {
			if lines[i] == h {
				i++
				break
			}
		}
		if i < 0 {
			i = 0
		}
		return strings.Join(lines[i:], "\n")
	},
	"tail": func(i int, s string) string {
		return strings.Join(strings.Split(s, "\n")[i:], "\n")
	},
	"lines": func(s string) []string {
		return strings.Split(s, "\n")
	},
	"lineEllipsis": func(i int, s string) string {
		if i <= 0 {
			panic(fmt.Errorf("must provide positive integer to lineEllipsis"))
		}

		scan := bufio.NewScanner(strings.NewReader(s))
		res := new(strings.Builder)

		early := false

		for scan.Scan() {
			if i == 0 {
				early = true
				break
			}

			res.WriteString(scan.Text() + "\n")
			i--
		}

		if err := scan.Err(); err != nil {
			panic(fmt.Errorf("failed to scan string: %v", err))
		}

		if early {
			res.WriteString("...\n")
		}

		return res.String()
	},
	"trimLinePrefixWhitespace": func(s string, l string) string {
		scan := bufio.NewScanner(strings.NewReader(s))
		res := new(strings.Builder)

		seen := false
		eatenWhiteSpace := false

		for scan.Scan() {
			line := scan.Text()

			if !seen {
				if l == line {
					seen = true
				}
				continue
			} else if !eatenWhiteSpace {
				if strings.TrimSpace(line) == "" {
					continue
				} else {
					eatenWhiteSpace = true
				}
			}

			res.WriteString(line + "\n")
		}

		if err := scan.Err(); err != nil {
			panic(fmt.Errorf("failed to scan string: %v", err))
		}

		return res.String()
	},
}

type cmdOut struct {
	Cmd string
	Out interface{}
}

func (p *processor) processTmplBlock() procFn {
	return p.processCommonBlock(tmplBlock, func(cmd string, out []byte) cmdOut {
		return cmdOut{
			Cmd: cmd,
			Out: string(out),
		}
	})
}
