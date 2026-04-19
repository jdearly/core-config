local ls  = require('luasnip')
local s   = ls.snippet
local t   = ls.text_node
local i   = ls.insert_node
local c   = ls.choice_node
local f   = ls.function_node
local d   = ls.dynamic_node
local sn  = ls.snippet_node
local rep = require('luasnip.extras').rep
local fmt = require('luasnip.extras.fmt').fmt

-- Helper: grab the current Go package name from the filename's directory
local function pkg_name()
  local dir = vim.fn.expand('%:p:h:t')
  if dir == '' then return 'main' end
  return dir
end

return {

  -- ===========================================================================
  -- Error handling
  -- ===========================================================================

  -- iferr: the workhorse. Choice 1 is wrapped error (default style).
  -- <C-l> cycles: wrapped → bare return → log+return
  s('iferr', fmt([[
if {} != nil {{
	{}
}}
]], {
    i(1, 'err'),
    c(2, {
      -- Choice 1: wrapped error with context (default)
      sn(nil, fmt('return fmt.Errorf("{}: %w", {})', {
        i(1, 'context'),
        i(2, 'err'),
      })),
      -- Choice 2: bare return
      sn(nil, fmt('return {}', { i(1, 'err') })),
      -- Choice 3: log and return
      sn(nil, fmt([[
log.Printf("{}: %v", {})
	return {}]], {
        i(1, 'context'),
        i(2, 'err'),
        rep(2),
      })),
    }),
  })),

  -- iferr for functions that return (value, error)
  s('iferre', fmt([[
{}, {} := {}
if {} != nil {{
	return {}, fmt.Errorf("{}: %w", {})
}}
]], {
    i(1, 'result'),
    i(2, 'err'),
    i(3, 'call()'),
    rep(2),
    i(4, 'nil'),
    i(5, 'context'),
    rep(2),
  })),

  -- ===========================================================================
  -- Functions
  -- ===========================================================================

  -- fn: function with context param. Choice toggles return type.
  s('fn', fmt([[
func {}(ctx context.Context{}) {} {{
	{}
}}
]], {
    i(1, 'doThing'),
    i(2),
    c(3, {
      t('error'),
      sn(nil, fmt('({}, error)', { i(1, 'string') })),
      t(''),
    }),
    i(0),
  })),

  -- method: method on a receiver
  s('meth', fmt([[
func ({} *{}) {}({}) {} {{
	{}
}}
]], {
    i(1, 's'),
    i(2, 'Service'),
    i(3, 'DoThing'),
    i(4, 'ctx context.Context'),
    c(5, {
      t('error'),
      sn(nil, fmt('({}, error)', { i(1, 'string') })),
      t(''),
    }),
    i(0),
  })),

  -- ===========================================================================
  -- Structs and constructors
  -- ===========================================================================

  s('struct', fmt([[
type {} struct {{
	{}
}}

func New{}({}) *{} {{
	return &{}{{
		{}
	}}
}}
]], {
    i(1, 'Name'),
    i(2, 'field Type'),
    rep(1),
    i(3),
    rep(1),
    rep(1),
    i(0),
  })),

  -- interface definition
  s('interface', fmt([[
type {} interface {{
	{}
}}
]], {
    i(1, 'Name'),
    i(0),
  })),

  -- ===========================================================================
  -- Testing
  -- ===========================================================================

  -- tdt: table-driven test
  s('tdt', fmt([[
func Test{}(t *testing.T) {{
	tests := []struct {{
		name string
		{}
	}}{{
		{{
			name: "{}",
			{}
		}},
	}}

	for _, tt := range tests {{
		t.Run(tt.name, func(t *testing.T) {{
			{}
		}})
	}}
}}
]], {
    i(1, 'FuncName'),
    i(2, 'input string\n\t\twant  string'),
    i(3, 'basic case'),
    i(4, '// test fields'),
    i(0),
  })),

  -- tf: simple test function
  s('tf', fmt([[
func Test{}(t *testing.T) {{
	{}
}}
]], {
    i(1, 'Name'),
    i(0),
  })),

  -- tb: benchmark function
  s('tb', fmt([[
func Benchmark{}(b *testing.B) {{
	for b.Loop() {{
		{}
	}}
}}
]], {
    i(1, 'Name'),
    i(0),
  })),

  -- ===========================================================================
  -- HTTP
  -- ===========================================================================

  -- handler: HTTP handler function
  s('handler', fmt([[
func {}(w http.ResponseWriter, r *http.Request) {{
	{}
}}
]], {
    i(1, 'handleIndex'),
    i(0),
  })),

  -- hfunc: inline http.HandlerFunc for use in mux registration
  s('hfunc', fmt([[
http.HandleFunc("{}", func(w http.ResponseWriter, r *http.Request) {{
	{}
}})
]], {
    i(1, '/path'),
    i(0),
  })),

  -- ===========================================================================
  -- Concurrency
  -- ===========================================================================

  -- gor: goroutine. Choice 1 is errgroup (production default), choice 2 is bare.
  s('gor', c(1, {
    -- Choice 1: errgroup
    sn(nil, fmt([[
g, ctx := errgroup.WithContext({})
g.Go(func() error {{
	{}
	return nil
}})
if err := g.Wait(); err != nil {{
	return fmt.Errorf("{}: %w", err)
}}]], {
      i(1, 'ctx'),
      i(2),
      i(3, 'goroutine failed'),
    })),
    -- Choice 2: bare goroutine
    sn(nil, fmt([[
go func() {{
	{}
}}()]], { i(1) })),
    -- Choice 3: goroutine with WaitGroup
    sn(nil, fmt([[
var wg sync.WaitGroup
wg.Add({})
go func() {{
	defer wg.Done()
	{}
}}()
wg.Wait()]], {
      i(1, '1'),
      i(2),
    })),
  })),

  -- chan: channel creation + select
  s('sel', fmt([[
select {{
case {} := <-{}:
	{}
case <-{}.Done():
	return {}.Err()
}}
]], {
    i(1, 'val'),
    i(2, 'ch'),
    i(3),
    i(4, 'ctx'),
    rep(4),
  })),

  -- ===========================================================================
  -- Common patterns
  -- ===========================================================================

  -- main: package main with func main
  s('main', fmt([[
package main

import (
	"fmt"
)

func main() {{
	{}
}}
]], { i(0) })),

  -- pkg: package declaration derived from directory name
  s('pkg', {
    f(function() return 'package ' .. pkg_name() end),
  }),

  -- defer with error check (common for Close calls)
  s('deferc', fmt([[
defer func() {{
	if cerr := {}.Close(); cerr != nil {{
		{}
	}}
}}()
]], {
    i(1, 'f'),
    c(2, {
      sn(nil, fmt('err = errors.Join(err, cerr)', {})),
      sn(nil, fmt('log.Printf("close failed: %v", cerr)', {})),
    }),
  })),

  -- context with timeout
  s('ctxt', fmt([[
ctx, cancel := context.WithTimeout({}, {})
defer cancel()
]], {
    i(1, 'ctx'),
    c(2, {
      sn(nil, fmt('{}*time.Second', { i(1, '5') })),
      sn(nil, fmt('{}*time.Millisecond', { i(1, '500') })),
    }),
  })),

  -- log line (choice: slog vs log)
  s('ll', c(1, {
    sn(nil, fmt('slog.{}("{}", {})', {
      c(1, { t('Info'), t('Error'), t('Debug'), t('Warn') }),
      i(2, 'message'),
      i(3, 'slog.String("key", val)'),
    })),
    sn(nil, fmt('log.Printf("{}: %v", {})', {
      i(1, 'message'),
      i(2, 'val'),
    })),
  })),

  -- type assertion with ok check
  s('ta', fmt([[
{}, ok := {}.({})
if !ok {{
	{}
}}
]], {
    i(1, 'val'),
    i(2, 'x'),
    i(3, 'Type'),
    i(0, 'return fmt.Errorf("unexpected type %T", x)'),
  })),

}
