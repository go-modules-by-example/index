package itemtype

// this is a temporary package until we get a resolution on https://github.com/golang/go/issues/24661
// because without that issue being resolved stringer doesn't work in a package that has non-standard
// library imports

//go:generate stringer -type=ItemType -output=gen_ItemType.go

type ItemType int

const (
	ItemError ItemType = iota

	ItemEOF

	ItemText

	ItemCodeFence
	ItemCode

	ItemTmplBlockStart
	ItemJsonBlockStart

	ItemBlockEnd
	ItemCommEnd

	ItemArg
	ItemQuoteArg
	ItemArgComment

	ItemOption
)
