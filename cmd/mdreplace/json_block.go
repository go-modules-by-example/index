package main

import (
	"encoding/json"
)

func (p *processor) processJsonBlock() procFn {
	return p.processCommonBlock(jsonBlock, func(cmd string, out []byte) cmdOut {
		var i interface{}

		if err := json.Unmarshal(out, &i); err != nil {
			p.errorf("failed to JSON parse %q: %v", string(out), err)
		}
		return cmdOut{
			Cmd: cmd,
			Out: i,
		}
	})
}
