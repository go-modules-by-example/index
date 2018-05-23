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
	"lines": func(s string) []string {
		return strings.Split(s, "\n")
	},
	"lineEllipsis": func(s string, i int) string {
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

func (p *processor) processTmplBlock() procFn {
	return p.processCommonBlock(tmplBlock, func(out []byte) interface{} {
		return string(out)
	})
}
