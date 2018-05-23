package main

import (
	"strings"
	"testing"
)

type exp struct {
	name string
	in   string
	ot   *string
	err  error
}

// in these tests, the expected output is the same as the input
// if output is not specified (helps to test idempotency)
var tests = []exp{
	{
		name: "simple test",
		in:   "This is a test",
	},
	{
		name: "code fence simple test",
		in: `This is a test
` + "```json" + `
contains a code block
` + "```" + `
Something`,
	},
	{
		name: "__TEMPLATE block simple",
		in: `This is a test
<!-- __TEMPLATE: echo -n hello world
{{.}}
-->
hello world
<!-- END -->
Something`,
	},
	{
		name: "__TEMPLATE block that references $DOLLAR",
		in: `This is a test
<!-- __TEMPLATE: echo -n hello world $DOLLAR
{{.}}
-->
hello world $
<!-- END -->
Something`,
	},
	{
		name: "__TEMPLATE block that contains a code fence block",
		in: `This is a test
<!-- __TEMPLATE: echo -n hello world
` + "```" + `
{{.}}
` + "```" + `
-->
` + "```" + `
hello world
` + "```" + `
<!-- END -->
Something`,
	},
	{
		name: "__TEMPLATE block quoted args",
		in: `This is a test
<!-- __TEMPLATE: echo -en "hello world"
{{.}}
-->
hello world
<!-- END -->
Something`,
	},
	{
		name: "__TEMPLATE block using lines func",
		in: `This is a test
<!-- __TEMPLATE: echo -en "hello\nworld"
{{ range (lines .) -}}
{{.}}
{{end -}}
-->
hello
world
<!-- END -->
Something`,
	},
	{
		name: "__JSON block simple",
		in: `This is a test
<!-- __JSON: vgo list -json .
{{.ImportPath}}
-->
myitcv.io/cmd/mdreplace
<!-- END -->
Something`,
	},
	{
		name: "__JSON block with bad original contents",
		in: `This is a test
<!-- __JSON: vgo list -json .
{{.ImportPath}}
-->
rubbish
<!-- END -->
Something`,
		ot: strVal(`This is a test
<!-- __JSON: vgo list -json .
{{.ImportPath}}
-->
myitcv.io/cmd/mdreplace
<!-- END -->
Something`),
	},
	{
		name: "__TEMPLATE nested quoted string",
		in: `<!-- __TEMPLATE: sh -c "BANANA=fruit; echo -n \"${DOLLAR}BANANA\""
{{.}}
-->
fruit
<!-- END -->
`,
	},
}

func strVal(s string) *string {
	return &s
}

func TestSimple(t *testing.T) {
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			debugf(">>>>>>>>>\n")
			in := strings.NewReader(test.in)
			out := new(strings.Builder)

			err := run(in, out)

			if (test.err == nil) != (err == nil) {
				t.Fatalf("unexpected error; wanted [%v]; got [%v]", test.err, err)
			}

			if test.err != nil && err != nil && test.err.Error() != err.Error() {
				t.Fatalf("incorrect error; wanted [%v]; got [%v]", test.err, err)
			}

			expOut := test.in

			if test.ot != nil {
				expOut = *(test.ot)
			}

			if v := out.String(); v != expOut {
				t.Fatalf("incorrect output; wanted:\n\n%q\n\ngot:\n\n%q\n", expOut, v)
			}
		})
	}
}
