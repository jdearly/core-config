local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local f = ls.function_node
local sn = ls.snippet_node
local rep = require("luasnip.extras").rep
local fmt = require("luasnip.extras.fmt").fmt

-- Helper: header guard name derived from filename
local function guard_name()
	local name = vim.fn.expand("%:t"):upper():gsub("[^%w]", "_")
	if name == "" then
		return "HEADER_H"
	end
	return name
end

return {

	-- guard: header guard (choice: #ifndef vs #pragma once)
	s(
		"guard",
		c(1, {
			sn(nil, {
				f(function()
					return "#ifndef " .. guard_name()
				end),
				t({ "", "" }),
				f(function()
					return "#define " .. guard_name()
				end),
				t({ "", "", "" }),
				i(1),
				t({ "", "", "" }),
				f(function()
					return "#endif /* " .. guard_name() .. " */"
				end),
			}),
			sn(nil, {
				t("#pragma once"),
				t({ "", "", "" }),
				i(1),
			}),
		})
	),

	-- main: main function
	-- 1 placeholder: body
	s(
		"main",
		fmt(
			[[
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{{
	{}

	return EXIT_SUCCESS;
}}
]],
			{ i(0) }
		)
	),

	-- inc: include
	s(
		"inc",
		c(1, {
			sn(nil, fmt("#include <{}>", { i(1, "stdio.h") })),
			sn(nil, fmt('#include "{}"', { i(1, "header.h") })),
		})
	),

	-- mal: malloc with NULL check
	-- 6 placeholders
	s(
		"mal",
		fmt(
			[[
{} *{} = malloc({} * sizeof({}));
if ({} == NULL) {{
	{}
}}
]],
			{
				i(1, "int"), -- 1: type
				i(2, "ptr"), -- 2: name
				i(3, "count"), -- 3: count
				rep(1), -- 4: type (sizeof)
				rep(2), -- 5: name (null check)
				c(4, { -- 6: error handling
					t('perror("malloc"); return NULL;'),
					t('perror("malloc"); exit(EXIT_FAILURE);'),
					sn(nil, fmt('perror("{}"); goto err;', { i(1, "malloc") })),
				}),
			}
		)
	),

	-- cal: calloc with NULL check
	-- 6 placeholders
	s(
		"cal",
		fmt(
			[[
{} *{} = calloc({}, sizeof({}));
if ({} == NULL) {{
	{}
}}
]],
			{
				i(1, "int"), -- 1
				i(2, "ptr"), -- 2
				i(3, "count"), -- 3
				rep(1), -- 4
				rep(2), -- 5
				c(4, { -- 6
					t('perror("calloc"); return NULL;'),
					t('perror("calloc"); exit(EXIT_FAILURE);'),
				}),
			}
		)
	),

	-- real: realloc with tmp pointer
	-- 6 placeholders
	s(
		"real",
		fmt(
			[[
{} *tmp = realloc({}, {} * sizeof({}));
if (tmp == NULL) {{
	{}
}}
{} = tmp;
]],
			{
				i(1, "int"), -- 1
				i(2, "ptr"), -- 2
				i(3, "new_count"), -- 3
				rep(1), -- 4
				c(4, { -- 5
					t("free(ptr); return NULL;"),
					t('perror("realloc"); exit(EXIT_FAILURE);'),
				}),
				rep(2), -- 6
			}
		)
	),

	-- struct: typedef struct vs tagged
	s(
		"struct",
		c(1, {
			sn(
				nil,
				fmt(
					[[
typedef struct {{
	{}
}} {};
]],
					{
						i(1, "int field;"),
						i(2, "Name"),
					}
				)
			),
			sn(
				nil,
				fmt(
					[[
struct {} {{
	{}
}};
]],
					{
						i(1, "name"),
						i(2, "int field;"),
					}
				)
			),
		})
	),

	-- enum: typedef enum vs bare
	s(
		"enum",
		c(1, {
			sn(
				nil,
				fmt(
					[[
typedef enum {{
	{},
	{},
}} {};
]],
					{
						i(1, "NAME_FIRST"),
						i(2, "NAME_SECOND"),
						i(3, "Name"),
					}
				)
			),
			sn(
				nil,
				fmt(
					[[
enum {} {{
	{},
	{},
}};
]],
					{
						i(1, "name"),
						i(2, "FIRST"),
						i(3, "SECOND"),
					}
				)
			),
		})
	),

	-- cleanup: goto-based cleanup pattern
	-- 7 placeholders
	s(
		"cleanup",
		fmt(
			[[
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
]],
			{
				i(1, "func"),
				i(2),
				c(3, { t("0"), t("-1") }),
				i(4, "/* resource acquisition */"),
				i(5, "/* main logic */"),
				c(6, { t("-1"), t("errno") }),
				i(7, "/* free resources */"),
			}
		)
	),

	-- retcheck: check return value
	-- 4 placeholders
	s(
		"retcheck",
		fmt(
			[[
{} = {};
if ({}) {{
	{}
}}
]],
			{
				i(1, "int ret"),
				i(2, "func()"),
				c(3, { t("ret < 0"), t("ret == -1"), t("ret == NULL") }),
				c(4, {
					sn(nil, fmt('perror("{}"); goto err;', { i(1, "func") })),
					t("return -1;"),
				}),
			}
		)
	),

	-- fopen: file open with error check
	-- 7 placeholders
	s(
		"fopen",
		fmt(
			[[
FILE *{} = fopen({}, "{}");
if ({} == NULL) {{
	{}
}}
{}
fclose({});
]],
			{
				i(1, "fp"),
				i(2, "filename"),
				c(3, { t("r"), t("w"), t("rb"), t("wb"), t("a") }),
				rep(1),
				c(4, {
					sn(nil, fmt('perror("{}"); return -1;', { i(1, "fopen") })),
					t("goto err;"),
				}),
				i(5, "/* read/write */"),
				rep(1),
			}
		)
	),

	-- pf: printf/fprintf
	s(
		"pf",
		c(1, {
			sn(nil, fmt('printf("{}", {});', { i(1, "%s\\n"), i(2, "arg") })),
			sn(nil, fmt('fprintf(stderr, "{}", {});', { i(1, "error: %s\\n"), i(2, "arg") })),
		})
	),

	-- fori: for loop
	-- 6 placeholders
	s(
		"fori",
		fmt(
			[[
for ({} {} = 0; {} < {}; {}++) {{
	{}
}}
]],
			{
				c(1, { t("size_t"), t("int") }),
				i(2, "i"),
				rep(2),
				i(3, "n"),
				rep(2),
				i(0),
			}
		)
	),

	-- forll: iterate linked list
	-- 7 placeholders
	s(
		"forll",
		fmt(
			[[
for ({} *{} = {}; {} != NULL; {} = {}->next) {{
	{}
}}
]],
			{
				i(1, "Node"),
				i(2, "cur"),
				i(3, "head"),
				rep(2),
				rep(2),
				rep(2),
				i(0),
			}
		)
	),

	-- sw: switch
	-- 6 placeholders
	s(
		"sw",
		fmt(
			[[
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
]],
			{
				i(1, "value"),
				i(2, "CASE_A"),
				i(3),
				i(4, "CASE_B"),
				i(5),
				i(6),
			}
		)
	),

	-- func: function definition
	-- 5 placeholders
	s(
		"func",
		fmt(
			[[
{}{}{}({})
{{
	{}
}}
]],
			{
				c(1, { t(""), t("static ") }),
				c(2, { t("int "), t("void "), t("bool "), t("size_t ") }),
				i(3, "func"),
				i(4, "void"),
				i(0),
			}
		)
	),

	-- cb: function pointer typedef
	-- 3 placeholders
	s(
		"cb",
		fmt(
			[[
typedef {} (*{})({});
]],
			{
				c(1, { t("void"), t("int"), t("bool") }),
				i(2, "Callback"),
				i(3, "void *ctx"),
			}
		)
	),

	-- sa: static_assert
	-- 2 placeholders
	s(
		"sa",
		fmt(
			[[
_Static_assert({}, "{}");
]],
			{
				i(1, "sizeof(int) == 4"),
				i(2, "expected 32-bit int"),
			}
		)
	),

	-- sdup: strdup with NULL check
	-- 4 placeholders
	s(
		"sdup",
		fmt(
			[[
char *{} = strdup({});
if ({} == NULL) {{
	{}
}}
]],
			{
				i(1, "copy"),
				i(2, "src"),
				rep(1),
				c(3, { t("return NULL;"), t("goto err;") }),
			}
		)
	),

	-- snpf: snprintf with truncation check
	-- 11 placeholders
	s(
		"snpf",
		fmt(
			[[
char {}[{}];
int {} = snprintf({}, sizeof({}), "{}", {});
if ({} < 0 || (size_t){} >= sizeof({})) {{
	{}
}}
]],
			{
				i(1, "buf"), -- 1
				i(2, "256"), -- 2
				i(3, "n"), -- 3
				rep(1), -- 4
				rep(1), -- 5
				i(4, "%s"), -- 6
				i(5, "arg"), -- 7
				rep(3), -- 8
				rep(3), -- 9
				rep(1), -- 10
				c(6, { -- 11
					t("return -1;"),
					t("goto err;"),
				}),
			}
		)
	),

	-- ifdef: conditional compilation
	s(
		"ifdef",
		c(1, {
			sn(
				nil,
				fmt(
					[[
#ifdef {}
{}
#endif /* {} */
]],
					{
						i(1, "DEBUG"),
						i(2),
						rep(1),
					}
				)
			),
			sn(
				nil,
				fmt(
					[[
#ifndef {}
{}
#endif /* {} */
]],
					{
						i(1, "FEATURE"),
						i(2),
						rep(1),
					}
				)
			),
		})
	),

	-- macro: function-like macro
	s(
		"macro",
		c(1, {
			sn(
				nil,
				fmt("#define {}({}) ({})", {
					i(1, "MAX"),
					i(2, "a, b"),
					i(3, "((a) > (b) ? (a) : (b))"),
				})
			),
			sn(
				nil,
				fmt("#define {}({}) {}", {
					i(1, "LOG"),
					i(2, "msg"),
					i(3, 'fprintf(stderr, "%s\\n", (msg))'),
				})
			),
		})
	),

	-- mem: memset/memcpy/memmove
	s(
		"mem",
		c(1, {
			sn(nil, fmt("memset({}, 0, sizeof({}));", { i(1, "buf"), rep(1) })),
			sn(nil, fmt("memcpy({}, {}, sizeof({}));", { i(1, "dst"), i(2, "src"), rep(1) })),
			sn(nil, fmt("memmove({}, {}, {});", { i(1, "dst"), i(2, "src"), i(3, "n") })),
		})
	),
}
