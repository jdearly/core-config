-- Each key is an insert-mode trigger and each body uses Neovim's native
-- LSP-style snippet grammar.
-- https://neovim.io/doc/user/lua.html#vim.snippet
---@type table<string, { description: string, body: string }>
return {
  [";fn"] = {
    description = "Go typed function returning an operating error",
    body = [[func ${1:functionName}(${2:parameters}) (${3:Result}, error) {
	$0
}]],
  },
  [";mth"] = {
    description = "Go value-receiver method",
    body = "func (${1:receiver} ${2:Type}) ${3:methodName}(${4:parameters})"
      .. " (${5:Result}, error) {\n\t$0\n}",
  },
  [";for"] = {
    description = "Go explicitly bounded index loop",
    body = [[if len(${1:values}) > ${2:valuesMax} {
	return ${3:zeroValue}, ${4:ErrTooManyValues}
}
for ${5:index} := range ${1:values} {
	$0
}]],
  },
  [";st"] = {
    description = "Go struct with private invariant-bearing state",
    body = [[type ${1:Type} struct {
	${2:value} ${3:ValueType}
}

$0]],
  },
  [";new"] = {
    description = "Go invariant-bearing constructor",
    body = [[func New${1:Type}(${2:value} ${3:ValueType}) (${1:Type}, error) {
	if ${4:invalid condition} {
		return ${1:Type}{}, ${5:ErrInvalidValue}
	}

	return ${1:Type}{${2:value}: ${2:value}}, nil
}]],
  },
  [";iface"] = {
    description = "Go interface for a justified implementation seam",
    body = [[type ${1:Name} interface {
	${2:Method}(${3:parameters}) (${4:Result}, error)
}

$0]],
  },
  [";sw"] = {
    description = "Go exhaustive state switch",
    body = [[switch ${1:state} {
case ${2:stateValue}:
	${3:handle state}
default:
	panic("unreachable state")
}

$0]],
  },
  [";err"] = {
    description = "Go wrapped operating error",
    body = [[if ${1:err} != nil {
	return ${2:zeroValue}, fmt.Errorf("${3:operation}: %w", ${1:err})
}

$0]],
  },
  [";parse"] = {
    description = "Go bounded parser into an invariant-bearing type",
    body = [[func Parse${1:Type}(raw string) (${1:Type}, error) {
	if len(raw) == 0 {
		return ${1:Type}{}, ${2:ErrEmptyValue}
	}
	if len(raw) > ${3:rawLengthMax} {
		return ${1:Type}{}, ${4:ErrValueTooLong}
	}

	return New${1:Type}(raw)
}]],
  },
  [";batch"] = {
    description = "Go bounded batch with one output allocation",
    body = [[func ${1:processBatch}(${2:inputs} []${3:Input}) ([]${4:Output}, error) {
	if len(${2:inputs}) > ${5:batchCountMax} {
		return nil, ${6:ErrBatchTooLarge}
	}

	outputs := make([]${4:Output}, len(${2:inputs}))
	for inputIndex, input := range ${2:inputs} {
		output, err := ${7:processOne}(input)
		if err != nil {
			return nil, fmt.Errorf("process input: %w", err)
		}
		outputs[inputIndex] = output
	}
	return outputs, nil
}]],
  },
  [";test"] = {
    description = "Go test covering valid, boundary, and invalid inputs",
    body = [[func Test${1:Name}(t *testing.T) {
	t.Run("valid", func(t *testing.T) {
		${2:test valid input}
	})
	t.Run("boundary", func(t *testing.T) {
		${3:test boundary input}
	})
	t.Run("invalid", func(t *testing.T) {
		${4:test invalid input}
	})
}]],
  },
}
