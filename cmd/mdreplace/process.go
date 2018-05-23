package main

import (
	"fmt"
	"io"

	"myitcv.io/vgo-by-example/cmd/mdreplace/internal/itemtype"
)

type procFn func() procFn

type processor struct {
	out   io.Writer
	items chan item
	curr  item
}

func process(items chan item, out io.Writer) (err error) {
	p := &processor{
		items: items,
		out:   out,
	}

	defer func() {
		if !panicErrors {
			if r := recover(); r != nil {
				err = r.(error)
			}
		}
	}()

	p.next()

	for state := p.processText; state != nil; {
		state = state()
	}

	return
}

func (p *processor) processText() procFn {

loop:
	for {
		i := p.curr

		switch i.typ {
		case itemtype.ItemEOF:
			break loop
		case itemtype.ItemError:
			p.errorf(i.val)
		case itemtype.ItemCodeFence:
			return p.processCode
		case itemtype.ItemTmplBlockStart:
			return p.processTmplBlock
		case itemtype.ItemJsonBlockStart:
			return p.processJsonBlock
		case itemtype.ItemText:
			p.print(i.val)
		default:
			p.errorf("unknown item %v", i.typ)
		}

		p.next()
	}

	return nil
}

func (p *processor) processCode() procFn {
	p.next()
	p.print(codeFence)

	// consume until the next codeFence
	for p.curr.typ != itemtype.ItemCodeFence {
		p.print(p.curr.val)
		p.next()
	}

	p.next()
	p.print(codeFence)

	return p.processText
}

func (p *processor) next() item {
	p.curr = <-p.items

	return p.curr
}

func (p *processor) errorf(format string, vs ...interface{}) {
	panic(fmt.Errorf(format, vs...))
}

func (p *processor) print(vs ...interface{}) {
	if _, err := fmt.Fprint(p.out, vs...); err != nil {
		p.errorf("failed print: %v", err)
	}
}

func (p *processor) printf(format string, vs ...interface{}) {
	if _, err := fmt.Fprintf(p.out, format, vs...); err != nil {
		p.errorf("failed printf: %v", err)
	}
}

func (p *processor) println(vs ...interface{}) {
	if _, err := fmt.Fprintln(p.out, vs...); err != nil {
		p.errorf("failed println: %v", err)
	}
}
