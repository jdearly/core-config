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

-- Helper: header guard name derived from filename
local function guard_name()
  local name = vim.fn.expand('%:t'):upper():gsub('[^%w]', '_')
  if name == '' then return 'HEADER_H' end
  return name
end

return {

  -- ===========================================================================
  -- File scaffolding
  -- ===========================================================================

  -- guard: header guard (choice: #ifndef vs #pragma once)
  s('guard', c(1, {
    sn(nil, {
      f(function() return '#ifndef ' .. guard_name() end),
      t({'', ''}),
      f(function() return '#define ' .. guard_name() end),
      t({'', '', ''}),
      i(1),
      t({'', '', ''}),
      f(function() return '#endif /* ' .. guard_name() .. ' */' end),
    }),
    sn(nil, {
      t('#pragma once'),
      t({'', '', ''}),
      i(1),
    }),
  })),

  -- main: main function
  s('main', c(1, {
    sn(nil, fmt([[
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{{
	{}

	return EXIT_SUCCESS;
}}
]], { i(1) })),
    sn(nil, fmt([[
#include <stdio.h>
#include <stdlib.h>

int main(void)
{{
	{}

	return EXIT_SUCCESS;
}}
]], { i(1) })),
  })),

  -- inc: include (choice: system vs local)
  s('inc', c(1, {
    sn(nil, fmt('#include <{}.h>', { i(1, 'stdio') })),
    sn(nil, fmt('#include "{}.h"', { i(1, 'header') })),
  })),

  -- incs: common include group
  s('incs', fmt([[
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
{}
]], { c(1, {
    t(''),
    t('#include <stdint.h>'),
    t({ '#include <stdint.h>', '#include <stdbool.h>' }),
    t({ '#include <stdint.h>', '#include <stdbool.h>', '#include <assert.h>' }),
  })})),

  -- ===========================================================================
  -- Memory allocation
  -- ===========================================================================

  -- mal: malloc with NULL check
  s('mal', fmt([[
{} *{} = malloc({}sizeof({}));
if ({} == NULL) {{
	{}
}}
]], {
    i(1, 'int'),
    i(2, 'ptr'),
    c(3, {
      t(''),
      sn(nil, fmt('{} * ', { i(1, 'count') })),
    }),
    rep(1),
    rep(2),
    c(4, {
      sn(nil, fmt([[
fprintf(stderr, "{}: %s\n", strerror(errno));
	return {};]], {
        i(1, 'malloc failed'),
        i(2, 'NULL'),
      })),
      sn(nil, fmt('return {};', { i(1, '-1') })),
      sn(nil, fmt([[
perror("{}");
	exit(EXIT_FAILURE);]], { i(1, 'malloc') })),
    }),
  })),

  -- cal: calloc with NULL check
  s('cal', fmt([[
{} *{} = calloc({}, sizeof({}));
if ({} == NULL) {{
	{}
}}
]], {
    i(1, 'int'),
    i(2, 'ptr'),
    i(3, 'count'),
    rep(1),
    rep(2),
    c(4, {
      sn(nil, fmt('return {};', { i(1, 'NULL') })),
      sn(nil, fmt([[
perror("{}");
	exit(EXIT_FAILURE);]], { i(1, 'calloc') })),
    }),
  })),

  -- real: realloc with tmp pointer pattern (avoids leak on failure)
  s('real', fmt([[
{} *tmp = realloc({}, {} * sizeof({}));
if (tmp == NULL) {{
	{}
}}
{} = tmp;
]], {
    i(1, 'int'),
    i(2, 'ptr'),
    i(3, 'new_count'),
    rep(1),
    c(4, {
      sn(nil, fmt([[
free({});
	return {};]], { i(1, 'ptr'), i(2, 'NULL') })),
      sn(nil, fmt([[
perror("realloc");
	free({});
	exit(EXIT_FAILURE);]], { i(1, 'ptr') })),
    }),
    rep(2),
  })),

  -- ===========================================================================
  -- Structs and typedefs
  -- ===========================================================================

  -- struct: struct definition
  s('struct', c(1, {
    -- Choice 1: typedef struct (common C idiom)
    sn(nil, fmt([[
typedef struct {{
	{}
}} {};
]], {
      i(1, 'int field;'),
      i(2, 'Name'),
    })),
    -- Choice 2: tagged struct
    sn(nil, fmt([[
struct {} {{
	{}
}};
]], {
      i(1, 'name'),
      i(2, 'int field;'),
    })),
  })),

  -- opaque: opaque struct pattern (header + source separation)
  s('opaque', fmt([[
/* In header: */
typedef struct {} {};

/* In source: */
struct {} {{
	{}
}};

{} *{}_create({})
{{
	{} *{} = malloc(sizeof({}));
	if ({} == NULL) {{
		return NULL;
	}}
	{}
	return {};
}}

void {}_destroy({} *{})
{{
	if ({} == NULL) {{
		return;
	}}
	{}
	free({});
}}
]], {
    i(1, 'Name'),
    rep(1),
    rep(1),
    i(2, 'int field;'),
    rep(1),
    -- _create
    f(function(args) return args[1][1]:lower() end, { 1 }),
    i(3),
    rep(1),
    i(4, 'self'),
    rep(1),
    rep(4),
    i(5, '/* init fields */'),
    rep(4),
    -- _destroy
    f(function(args) return args[1][1]:lower() end, { 1 }),
    rep(1),
    rep(4),
    rep(4),
    i(6, '/* free owned resources */'),
    rep(4),
  })),

  -- enum: enum definition
  s('enum', c(1, {
    sn(nil, fmt([[
typedef enum {{
	{},
	{},
	{}_COUNT,
}} {};
]], {
      i(1, 'NAME_FIRST'),
      i(2, 'NAME_SECOND'),
      f(function(args)
        local first = args[1][1]
        local prefix = first:match('^(%u+)_') or 'ENUM'
        return prefix
      end, { 1 }),
      i(3, 'Name'),
    })),
    sn(nil, fmt([[
enum {} {{
	{},
	{},
}};
]], {
      i(1, 'name'),
      i(2, 'FIRST'),
      i(3, 'SECOND'),
    })),
  })),

  -- ===========================================================================
  -- Error handling patterns
  -- ===========================================================================

  -- goto_cleanup: goto-based cleanup pattern
  s('cleanup', fmt([[
int {}({})
{{
	int ret = {};
	{}

	{}

	goto done;

err:
	ret = {};
done:
	{}
	return ret;
}}
]], {
    i(1, 'func'),
    i(2),
    c(3, { t('0'), t('-1') }),
    i(4, '/* resource acquisition */'),
    i(5, '/* main logic */'),
    c(6, { t('-1'), t('errno') }),
    i(7, '/* free resources */'),
  })),

  -- retcheck: check return value pattern
  s('retcheck', fmt([[
{} = {}({});
if ({}{}) {{
	{}
}}
]], {
    c(1, {
      sn(nil, fmt('{} {}', { i(1, 'int'), i(2, 'ret') })),
      sn(nil, fmt('{} *{}', { i(1, 'void'), i(2, 'ptr') })),
    }),
    i(3, 'function'),
    i(4),
    c(5, {
      sn(nil, { i(1, 'ret'), t(' < 0') }),
      sn(nil, { i(1, 'ret'), t(' == -1') }),
      sn(nil, { i(1, 'ptr'), t(' == NULL') }),
    }),
    t(''),
    c(6, {
      sn(nil, fmt([[
perror("{}");
	goto err;]], { i(1, 'function') })),
      sn(nil, fmt('return {};', { i(1, '-1') })),
      sn(nil, fmt([[
fprintf(stderr, "{}: %s\n", strerror(errno));
	return {};]], {
        i(1, 'function failed'),
        i(2, '-1'),
      })),
    }),
  })),

  -- ===========================================================================
  -- I/O
  -- ===========================================================================

  -- fopen: file open with error check
  s('fopen', fmt([[
FILE *{} = fopen({}, "{}");
if ({} == NULL) {{
	{}
}}
{}
fclose({});
]], {
    i(1, 'fp'),
    i(2, 'filename'),
    c(3, { t('r'), t('w'), t('rb'), t('wb'), t('a') }),
    rep(1),
    c(4, {
      sn(nil, fmt([[
perror("{}");
	return {};]], { i(1, 'fopen'), i(2, '-1') })),
      sn(nil, fmt('goto err;', {})),
    }),
    i(5, '/* read/write */'),
    rep(1),
  })),

  -- pf: printf/fprintf
  s('pf', c(1, {
    sn(nil, fmt('printf("{}" {});', {
      i(1, '%s\\n'),
      c(2, { t(''), sn(nil, fmt(', {}', { i(1, 'arg') })) }),
    })),
    sn(nil, fmt('fprintf(stderr, "{}" {});', {
      i(1, 'error: %s\\n'),
      c(2, { t(''), sn(nil, fmt(', {}', { i(1, 'arg') })) }),
    })),
  })),

  -- ===========================================================================
  -- Loops and control flow
  -- ===========================================================================

  -- fori: for loop with size_t index
  s('fori', fmt([[
for ({} {} = 0; {} < {}; {}++) {{
	{}
}}
]], {
    c(1, { t('size_t'), t('int') }),
    i(2, 'i'),
    rep(2),
    i(3, 'n'),
    rep(2),
    i(0),
  })),

  -- forll: iterate linked list
  s('forll', fmt([[
for ({} *{} = {}; {} != NULL; {} = {}->next) {{
	{}
}}
]], {
    i(1, 'Node'),
    i(2, 'cur'),
    i(3, 'head'),
    rep(2),
    rep(2),
    rep(2),
    i(0),
  })),

  -- switch: switch statement
  s('sw', fmt([[
switch ({}) {{
case {}:
	{}
	break;
case {}:
	{}
	break;
default:
	{}
	break;
}}
]], {
    i(1, 'value'),
    i(2, 'CASE_A'),
    i(3),
    i(4, 'CASE_B'),
    i(5),
    i(6),
  })),

  -- ===========================================================================
  -- Data structures (inline patterns)
  -- ===========================================================================

  -- dynarr: dynamic array / vector pattern
  s('dynarr', fmt([[
typedef struct {{
	{} *data;
	size_t len;
	size_t cap;
}} {};

static int {}_init({} *{}, size_t cap)
{{
	{}->data = malloc(cap * sizeof({}));
	if ({}->data == NULL) {{
		return -1;
	}}
	{}->len = 0;
	{}->cap = cap;
	return 0;
}}

static int {}_push({} *{}, {} val)
{{
	if ({}->len >= {}->cap) {{
		size_t new_cap = {}->cap * 2;
		{} *tmp = realloc({}->data, new_cap * sizeof({}));
		if (tmp == NULL) {{
			return -1;
		}}
		{}->data = tmp;
		{}->cap = new_cap;
	}}
	{}->data[{}->len++] = val;
	return 0;
}}

static void {}_free({} *{})
{{
	free({}->data);
	{}->data = NULL;
	{}->len = 0;
	{}->cap = 0;
}}
]], {
    i(1, 'int'),
    i(2, 'Vec'),
    -- _init
    f(function(a) return a[1][1]:lower() end, {2}),
    rep(2), i(3, 'v'),
    rep(3), rep(1),
    rep(3),
    rep(3), rep(3),
    -- _push
    f(function(a) return a[1][1]:lower() end, {2}),
    rep(2), rep(3), rep(1),
    rep(3), rep(3),
    rep(3),
    rep(1), rep(3), rep(1),
    rep(3), rep(3),
    rep(3), rep(3),
    -- _free
    f(function(a) return a[1][1]:lower() end, {2}),
    rep(2), rep(3),
    rep(3),
    rep(3), rep(3),
  })),

  -- ===========================================================================
  -- Preprocessor
  -- ===========================================================================

  -- ifdef: conditional compilation
  s('ifdef', c(1, {
    sn(nil, fmt([[
#ifdef {}
{}
#endif /* {} */]], {
      i(1, 'DEBUG'),
      i(2),
      rep(1),
    })),
    sn(nil, fmt([[
#ifndef {}
{}
#endif /* {} */]], {
      i(1, 'FEATURE'),
      i(2),
      rep(1),
    })),
    sn(nil, fmt([[
#if defined({}) && defined({})
{}
#endif]], {
      i(1, 'FEATURE_A'),
      i(2, 'FEATURE_B'),
      i(3),
    })),
  })),

  -- macro: function-like macro
  s('macro', c(1, {
    sn(nil, fmt([[
#define {}({}) ({})]], {
      i(1, 'MAX'),
      i(2, 'a, b'),
      i(3, '((a) > (b) ? (a) : (b))'),
    })),
    sn(nil, fmt([[
#define {}({}) \
	do {{ \
		{}; \
	}} while (0)]], {
      i(1, 'LOG'),
      i(2, 'msg'),
      i(3, 'fprintf(stderr, "%s\\n", (msg))'),
    })),
  })),

  -- sa: static_assert (C11)
  s('sa', fmt([[
_Static_assert({}, "{}");
]], {
    i(1, 'sizeof(int) == 4'),
    i(2, 'expected 32-bit int'),
  })),

  -- ===========================================================================
  -- Function declarations
  -- ===========================================================================

  -- func: function definition
  s('func', fmt([[
{}{}{}({})
{{
	{}
}}
]], {
    c(1, { t(''), t('static ') }),
    c(2, {
      t('int '),
      t('void '),
      t('bool '),
      sn(nil, fmt('{} *', { i(1, 'char') })),
      i(nil, 'size_t '),
    }),
    i(3, 'func'),
    c(4, {
      t('void'),
      i(nil, 'int arg'),
      sn(nil, fmt('const {} *{}', { i(1, 'char'), i(2, 'str') })),
      sn(nil, fmt('{} *{}, size_t {}', { i(1, 'int'), i(2, 'arr'), i(3, 'len') })),
    }),
    i(0),
  })),

  -- cb: function pointer typedef
  s('cb', fmt([[
typedef {} (*{})({});
]], {
    c(1, { t('void'), t('int'), t('bool') }),
    i(2, 'Callback'),
    i(3, 'void *ctx'),
  })),

  -- ===========================================================================
  -- Common string / memory operations
  -- ===========================================================================

  -- strdup: strdup with NULL check
  s('sdup', fmt([[
char *{} = strdup({});
if ({} == NULL) {{
	{}
}}
]], {
    i(1, 'copy'),
    i(2, 'src'),
    rep(1),
    c(3, {
      sn(nil, fmt('return {};', { i(1, 'NULL') })),
      t('goto err;'),
    }),
  })),

  -- snpf: snprintf (safe formatted string)
  s('snpf', fmt([[
char {}[{}];
int {} = snprintf({}, sizeof({}), "{}", {});
if ({} < 0 || (size_t){} >= sizeof({})) {{
	{}
}}
]], {
    i(1, 'buf'),
    i(2, '256'),
    i(3, 'n'),
    rep(1),
    rep(1),
    i(4, '%s'),
    i(5, 'arg'),
    rep(3),
    rep(3),
    rep(1),
    c(6, {
      sn(nil, fmt('return {};', { i(1, '-1') })),
      t('goto err;'),
    }),
  })),

  -- memset/memcpy
  s('mem', c(1, {
    sn(nil, fmt('memset({}, 0, sizeof({}));', { i(1, 'buf'), rep(1) })),
    sn(nil, fmt('memcpy({}, {}, sizeof({}));', { i(1, 'dst'), i(2, 'src'), rep(1) })),
    sn(nil, fmt('memmove({}, {}, {});', { i(1, 'dst'), i(2, 'src'), i(3, 'n') })),
  })),

}
