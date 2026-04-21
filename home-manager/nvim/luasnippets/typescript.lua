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

-- Helper: derive a PascalCase name from current filename
local function file_name_pascal()
  local name = vim.fn.expand('%:t:r')
  if name == '' then return 'Name' end
  return name:sub(1, 1):upper() .. name:sub(2)
end

return {

  -- ===========================================================================
  -- Functions
  -- ===========================================================================

  -- fn: named function (choice: sync vs async, export vs local)
  s('fn', fmt([[
{}function {}({}): {} {{
  {}
}}
]], {
    c(1, {
      t('export '),
      t('export async '),
      t('async '),
      t(''),
    }),
    i(2, 'name'),
    i(3),
    c(4, {
      t('void'),
      sn(nil, fmt('Promise<{}>', { i(1, 'void') })),
      i(nil, 'string'),
    }),
    i(0),
  })),

  -- arrow: const arrow function
  s('arrow', fmt([[
{}const {} = ({}){} => {{
  {}
}}
]], {
    c(1, { t('export '), t('') }),
    i(2, 'fn'),
    i(3),
    c(4, {
      t(''),
      sn(nil, fmt(': {}', { i(1, 'void') })),
    }),
    i(0),
  })),

  -- ===========================================================================
  -- Error handling
  -- ===========================================================================

  -- trya: try/catch (choice: instanceof check vs rethrow vs log)
  s('trya', fmt([[
try {{
  {}
}} catch (error) {{
  {}
}}
]], {
    i(1),
    c(2, {
      sn(nil, fmt([[
if (error instanceof Error) {{
    {}
  }}]], {
        i(1, 'throw error'),
      })),
      sn(nil, fmt('throw new Error("{}", {{ cause: error }})', { i(1, 'context') })),
      sn(nil, fmt('console.error("{}", error)', { i(1, 'operation failed') })),
    }),
  })),

  -- ===========================================================================
  -- Types, interfaces, generics
  -- ===========================================================================

  -- iface: interface
  s('iface', fmt([[
{}interface {} {{
  {}
}}
]], {
    c(1, { t('export '), t('') }),
    i(2, 'Name'),
    i(0),
  })),

  -- type: type alias
  s('type', fmt([[
{}type {} = {}
]], {
    c(1, { t('export '), t('') }),
    i(2, 'Name'),
    i(0),
  })),

  -- du: discriminated union
  s('du', fmt([[
{}type {} =
  | {{ kind: "{}"; {} }}
  | {{ kind: "{}"; {} }}
]], {
    c(1, { t('export '), t('') }),
    i(2, 'Result'),
    i(3, 'success'),
    i(4, 'data: unknown'),
    i(5, 'error'),
    i(6, 'message: string'),
  })),

  -- tg: type guard function
  s('tg', fmt([[
function is{}(value: unknown): value is {} {{
  return {}
}}
]], {
    i(1, 'MyType'),
    rep(1),
    i(2, 'typeof value === "object" && value !== null'),
  })),

  -- ge: generic function
  s('ge', fmt([[
function {}<{}>({}): {} {{
  {}
}}
]], {
    i(1, 'identity'),
    i(2, 'T'),
    i(3, 'value: T'),
    i(4, 'T'),
    i(0, 'return value'),
  })),

  -- enum: const enum / union (choice between them)
  s('enum', c(1, {
    -- Choice 1: string literal union (preferred in modern TS)
    sn(nil, fmt([[
export const {} = [{}] as const
type {} = (typeof {})[number]
]], {
      i(1, 'STATUSES'),
      i(2, '"active", "inactive", "pending"'),
      i(3, 'Status'),
      rep(1),
    })),
    -- Choice 2: actual enum
    sn(nil, fmt([[
export enum {} {{
  {}
}}]], {
      i(1, 'Status'),
      i(2, 'Active = "active",'),
    })),
  })),

  -- mapped: mapped / utility type
  s('mapped', c(1, {
    sn(nil, fmt('type {} = Partial<{}>', { i(1, 'Update'), i(2, 'Base') })),
    sn(nil, fmt('type {} = Pick<{}, {}>', { i(1, 'Summary'), i(2, 'Base'), i(3, '"id" | "name"') })),
    sn(nil, fmt('type {} = Omit<{}, {}>', { i(1, 'Public'), i(2, 'Base'), i(3, '"password"') })),
    sn(nil, fmt('type {} = Record<{}, {}>', { i(1, 'Lookup'), i(2, 'string'), i(3, 'unknown') })),
    sn(nil, fmt('type {} = Readonly<{}>', { i(1, 'Frozen'), i(2, 'Base') })),
  })),

  -- ===========================================================================
  -- Classes
  -- ===========================================================================

  -- class: class with constructor
  s('class', fmt([[
{}class {} {{
  {}

  constructor({}) {{
    {}
  }}

  {}
}}
]], {
    c(1, { t('export '), t('export abstract '), t('') }),
    i(2, 'Name'),
    i(3, 'private readonly field: string'),
    i(4, 'field: string'),
    i(5, 'this.field = field'),
    i(0),
  })),

  -- ===========================================================================
  -- Async patterns (core language)
  -- ===========================================================================

  -- prom: Promise constructor
  s('prom', fmt([[
new Promise<{}>((resolve, reject) => {{
  {}
}})
]], {
    i(1, 'string'),
    i(0),
  })),

  -- pall: Promise.all / allSettled / race
  s('pall', c(1, {
    sn(nil, fmt([[
const [{}] = await Promise.all([
  {},
])]], {
      i(1, 'a, b'),
      i(2),
    })),
    sn(nil, fmt([[
const {} = await Promise.allSettled([
  {},
])]], {
      i(1, 'results'),
      i(2),
    })),
    sn(nil, fmt([[
const {} = await Promise.race([
  {},
])]], {
      i(1, 'winner'),
      i(2),
    })),
  })),

  -- timeout: AbortController with timeout
  s('abort', fmt([[
const {} = new AbortController()
const {} = setTimeout(() => {}.abort(), {})

try {{
  {}
}} finally {{
  clearTimeout({})
}}
]], {
    i(1, 'controller'),
    i(2, 'timeoutId'),
    rep(1),
    i(3, '5000'),
    i(0),
    rep(2),
  })),

  -- iter: async iterator pattern
  s('aiter', fmt([[
async function* {}({}) {{
  {}
  yield {}
}}
]], {
    i(1, 'generate'),
    i(2),
    i(3),
    i(0, 'value'),
  })),

  -- forawait: for-await-of loop
  s('forawait', fmt([[
for await (const {} of {}) {{
  {}
}}
]], {
    i(1, 'item'),
    i(2, 'stream'),
    i(0),
  })),

  -- ===========================================================================
  -- Node.js stdlib
  -- ===========================================================================

  -- readfile: fs read (choice: readFile vs createReadStream)
  s('readfile', c(1, {
    sn(nil, fmt([[
import {{ readFile }} from "node:fs/promises"

const {} = await readFile({}, "utf-8")]], {
      i(1, 'content'),
      i(2, 'filepath'),
    })),
    sn(nil, fmt([[
import {{ createReadStream }} from "node:fs"

const {} = createReadStream({}, {{ encoding: "utf-8" }})
for await (const chunk of {}) {{
  {}
}}]], {
      i(1, 'stream'),
      i(2, 'filepath'),
      rep(1),
      i(3),
    })),
  })),

  -- writefile: fs write
  s('writefile', fmt([[
import {{ writeFile }} from "node:fs/promises"

await writeFile({}, {}, "utf-8")
]], {
    i(1, 'filepath'),
    i(2, 'data'),
  })),

  -- httpserv: Node.js http server
  s('httpserv', fmt([[
import {{ createServer }} from "node:http"

const server = createServer((req, res) => {{
  {}
}})

server.listen({}, () => {{
  console.log(`Listening on port ${{{}}}`)
}})
]], {
    i(1, 'res.writeHead(200, { "Content-Type": "application/json" })\n  res.end(JSON.stringify({ ok: true }))'),
    i(2, 'port'),
    rep(2),
  })),

  -- spawn: child_process
  s('spawn', fmt([[
import {{ {} }} from "node:child_process"

const {} = {}("{}", [{}]{})
]], {
    c(1, { t('spawn'), t('execFile'), t('fork') }),
    i(2, 'child'),
    rep(1),
    i(3, 'command'),
    i(4),
    c(5, {
      t(''),
      sn(nil, fmt(', {{ cwd: {} }}', { i(1, 'process.cwd()') })),
    }),
  })),

  -- path: path operations
  s('pathj', fmt([[
import {{ {} }} from "node:path"

const {} = {}({})
]], {
    c(1, { t('join'), t('resolve'), t('dirname'), t('basename'), t('extname') }),
    i(2, 'result'),
    rep(1),
    i(3),
  })),

  -- env: environment variable with fallback
  s('env', fmt([[
const {} = process.env.{} ?? {}
]], {
    i(1, 'port'),
    i(2, 'PORT'),
    c(3, {
      sn(nil, fmt('"{}"', { i(1, '3000') })),
      t('(() => { throw new Error("Missing env var") })()'),
    }),
  })),

  -- ee: EventEmitter subclass
  s('ee', fmt([[
import {{ EventEmitter }} from "node:events"

class {} extends EventEmitter {{
  {}
}}
]], {
    i(1, 'MyEmitter'),
    i(0),
  })),

  -- ===========================================================================
  -- node:test (built-in test runner)
  -- ===========================================================================

  -- desc: describe + it block
  s('desc', fmt([[
import {{ describe, it{} }} from "node:test"
import assert from "node:assert/strict"

describe("{}", () => {{
  {}it("{}", {}() => {{
    {}
  }})
}})
]], {
    c(1, { t(''), t(', before, after'), t(', beforeEach, afterEach') }),
    i(2, 'module'),
    c(3, {
      t(''),
      sn(nil, fmt([[
before(() => {{
    {}
  }})

  after(() => {{
    {}
  }})

  ]], { i(1, '// setup'), i(2, '// teardown') })),
    }),
    i(4, 'should work'),
    c(5, { t(''), t('async ') }),
    i(0, 'assert.strictEqual(actual, expected)'),
  })),

  -- test: single test function
  s('test', fmt([[
import test from "node:test"
import assert from "node:assert/strict"

test("{}", {}() => {{
  {}
}})
]], {
    i(1, 'description'),
    c(2, { t(''), t('async ') }),
    i(0, 'assert.ok(true)'),
  })),

  -- it: bare it() inside existing describe
  s('it', fmt([[
it("{}", {}() => {{
  {}
}})
]], {
    i(1, 'should work'),
    c(2, { t(''), t('async ') }),
    i(0),
  })),

  -- mock: node:test mock
  s('mock', fmt([[
const {} = t.mock.fn({})
]], {
    i(1, 'mockFn'),
    c(2, {
      t(''),
      sn(nil, fmt('() => {}', { i(1, 'value') })),
    }),
  })),

  -- ===========================================================================
  -- Common patterns
  -- ===========================================================================

  -- fetch: typed fetch (no library, just built-in)
  s('fetch', fmt([[
const response = await fetch({}{})
if (!response.ok) {{
  throw new Error(`{} ${{response.status}}: ${{response.statusText}}`)
}}
const {}{} = await response.json()
]], {
    i(1, 'url'),
    c(2, {
      t(''),
      sn(nil, fmt(', {{\n  method: "{}",\n  headers: {{ "Content-Type": "application/json" }},\n  body: JSON.stringify({}),\n}}', {
        c(1, { t('POST'), t('PUT'), t('PATCH'), t('DELETE') }),
        i(2, 'body'),
      })),
      sn(nil, fmt(', {{ signal: {}.signal }}', { i(1, 'controller') })),
    }),
    i(3, 'Request failed'),
    i(4, 'data'),
    c(5, {
      t(''),
      sn(nil, fmt(' as {}', { i(1, 'unknown') })),
    }),
  })),

  -- map: new Map / Set / WeakMap
  s('coll', c(1, {
    sn(nil, fmt('const {} = new Map<{}, {}>()', {
      i(1, 'map'),
      i(2, 'string'),
      i(3, 'unknown'),
    })),
    sn(nil, fmt('const {} = new Set<{}>()', {
      i(1, 'set'),
      i(2, 'string'),
    })),
    sn(nil, fmt('const {} = new WeakMap<{}, {}>()', {
      i(1, 'cache'),
      i(2, 'object'),
      i(3, 'unknown'),
    })),
  })),

  -- using: explicit resource management (TS 5.2+)
  s('using', fmt([[
await using {} = {}
]], {
    i(1, 'resource'),
    i(2, 'acquireResource()'),
  })),

  -- log: console methods
  s('log', c(1, {
    sn(nil, fmt('console.log({})', { i(1) })),
    sn(nil, fmt('console.error({})', { i(1) })),
    sn(nil, fmt('console.time("{}")\n{}\nconsole.timeEnd("{}")', {
      i(1, 'label'),
      i(2),
      rep(1),
    })),
    sn(nil, fmt('console.table({})', { i(1) })),
  })),

  -- nimp: node: prefixed import
  s('nimp', fmt([[
import {{ {} }} from "node:{}"
]], {
    i(2, 'readFile'),
    c(1, {
      t('fs/promises'),
      t('fs'),
      t('path'),
      t('http'),
      t('https'),
      t('child_process'),
      t('events'),
      t('stream'),
      t('util'),
      t('crypto'),
      t('os'),
      t('url'),
      t('worker_threads'),
      t('test'),
      t('assert/strict'),
    }),
  })),

}
