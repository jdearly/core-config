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

-- Helper: derive module name from filename
local function module_name()
  local name = vim.fn.expand('%:t:r')
  if name == '' then return 'module' end
  return name
end

return {

  -- ===========================================================================
  -- Dataclasses and typing
  -- ===========================================================================

  -- dc: dataclass (choice: frozen/slots/basic)
  s('dc', fmt([[
@dataclass{}
class {}:
    {}
]], {
    c(1, {
      t('(frozen=True, slots=True)'),
      t('(slots=True)'),
      t(''),
      t('(frozen=True)'),
    }),
    i(2, 'Name'),
    i(0, 'field: str'),
  })),

  -- dcf: dataclass with factory defaults
  s('dcf', fmt([[
@dataclass{}
class {}:
    {}: {}
    {}: {} = field(default_factory={})
]], {
    c(1, { t('(slots=True)'), t('') }),
    i(2, 'Config'),
    i(3, 'name'),
    i(4, 'str'),
    i(5, 'items'),
    i(6, 'list[str]'),
    i(7, 'list'),
  })),

  -- typed: TypedDict
  s('typed', fmt([[
class {}(TypedDict{}):
    {}
]], {
    i(1, 'Options'),
    c(2, { t(''), t(', total=False') }),
    i(0, 'key: str'),
  })),

  -- ne: NamedTuple
  s('ne', fmt([[
class {}(NamedTuple):
    {}
]], {
    i(1, 'Point'),
    i(0, 'x: float\n    y: float'),
  })),

  -- alias: type alias (3.12+ syntax vs older)
  s('alias', c(1, {
    sn(nil, fmt('type {} = {}', { i(1, 'Name'), i(2, 'str | int') })),
    sn(nil, fmt('{}: TypeAlias = {}', { i(1, 'Name'), i(2, 'str | int') })),
  })),

  -- ===========================================================================
  -- Functions
  -- ===========================================================================

  -- def: function definition
  s('def', fmt([[
def {}({}) -> {}:
    {}{}
]], {
    i(1, 'func'),
    i(2, 'self'),
    c(3, {
      t('None'),
      i(nil, 'str'),
      i(nil, 'bool'),
      i(nil, 'int'),
      i(nil, 'list'),
    }),
    c(4, {
      t(''),
      sn(nil, fmt([[
"""{}"""
    ]], { i(1, 'Description.') })),
    }),
    i(0, 'pass'),
  })),

  -- adef: async function
  s('adef', fmt([[
async def {}({}) -> {}:
    {}
]], {
    i(1, 'func'),
    i(2),
    c(3, {
      t('None'),
      i(nil, 'str'),
    }),
    i(0, 'pass'),
  })),

  -- ===========================================================================
  -- Classes
  -- ===========================================================================

  -- cls: class with __init__
  s('cls', fmt([[
class {}{}:
    {}def __init__(self{}) -> None:
        {}

    {}
]], {
    i(1, 'Name'),
    c(2, { t(''), sn(nil, fmt('({})', { i(1, 'Base') })) }),
    c(3, {
      t(''),
      sn(nil, fmt([[
"""{}"""

    ]], { i(1, 'Description.') })),
    }),
    i(4),
    i(5, 'pass'),
    i(0),
  })),

  -- prop: property
  s('prop', fmt([[
@property
def {}(self) -> {}:
    return self._{}

@{}.setter
def {}(self, value: {}) -> None:
    self._{} = value
]], {
    i(1, 'name'),
    i(2, 'str'),
    rep(1),
    rep(1),
    rep(1),
    rep(2),
    rep(1),
  })),

  -- abs: abstract method
  s('abs', fmt([[
@abstractmethod
def {}(self{}) -> {}:
    ...
]], {
    i(1, 'method'),
    i(2),
    i(3, 'None'),
  })),

  -- dunder: common dunder methods
  s('dunder', c(1, {
    sn(nil, fmt([[
def __repr__(self) -> str:
    return f"{}({{{}}})"]], {
      i(1, 'Name'),
      i(2, 'self.field'),
    })),
    sn(nil, fmt([[
def __str__(self) -> str:
    return {}]], {
      i(1, 'f"{self.field}"'),
    })),
    sn(nil, fmt([[
def __eq__(self, other: object) -> bool:
    if not isinstance(other, {}):
        return NotImplemented
    return {}]], {
      i(1, 'type(self)'),
      i(2, 'self.field == other.field'),
    })),
    sn(nil, fmt([[
def __hash__(self) -> int:
    return hash({})]], {
      i(1, '(self.field,)'),
    })),
    sn(nil, fmt([[
def __len__(self) -> int:
    return len(self.{})]], {
      i(1, 'items'),
    })),
    sn(nil, fmt([[
def __contains__(self, item: {}) -> bool:
    return item in self.{}]], {
      i(1, 'str'),
      i(2, 'items'),
    })),
  })),

  -- ===========================================================================
  -- Context managers and decorators
  -- ===========================================================================

  -- ctx: context manager (choice: class-based vs generator)
  s('ctx', c(1, {
    -- Choice 1: generator-based (preferred)
    sn(nil, fmt([[
@contextmanager
def {}({}) -> Generator[{}, None, None]:
    {} = {}
    try:
        yield {}
    finally:
        {}]], {
      i(1, 'managed'),
      i(2),
      i(3, 'Resource'),
      i(4, 'resource'),
      i(5, 'acquire()'),
      rep(4),
      i(6, 'resource.close()'),
    })),
    -- Choice 2: async generator-based
    sn(nil, fmt([[
@asynccontextmanager
async def {}({}) -> AsyncGenerator[{}, None]:
    {} = await {}
    try:
        yield {}
    finally:
        await {}]], {
      i(1, 'managed'),
      i(2),
      i(3, 'Resource'),
      i(4, 'resource'),
      i(5, 'acquire()'),
      rep(4),
      i(6, 'resource.close()'),
    })),
  })),

  -- dec: decorator (choice: simple vs with args)
  s('dec', c(1, {
    -- Choice 1: simple decorator
    sn(nil, fmt([[
def {}(func: Callable[..., T]) -> Callable[..., T]:
    @wraps(func)
    def wrapper(*args: Any, **kwargs: Any) -> T:
        {}
        return func(*args, **kwargs)
    return wrapper]], {
      i(1, 'decorator'),
      i(2, '# before'),
    })),
    -- Choice 2: decorator with arguments
    sn(nil, fmt([[
def {}({}) -> Callable[[Callable[..., T]], Callable[..., T]]:
    def decorator(func: Callable[..., T]) -> Callable[..., T]:
        @wraps(func)
        def wrapper(*args: Any, **kwargs: Any) -> T:
            {}
            return func(*args, **kwargs)
        return wrapper
    return decorator]], {
      i(1, 'decorator'),
      i(2, 'arg: str'),
      i(3, '# before'),
    })),
  })),

  -- ===========================================================================
  -- Error handling
  -- ===========================================================================

  -- tryex: try/except
  s('tryex', fmt([[
try:
    {}
except {}{} as e:
    {}
]], {
    i(1, 'pass'),
    c(2, {
      t('Exception'),
      t('ValueError'),
      t('TypeError'),
      t('KeyError'),
      t('OSError'),
      t('RuntimeError'),
      sn(nil, fmt('({})', { i(1, 'ValueError, TypeError') })),
    }),
    t(''),
    c(3, {
      sn(nil, fmt('raise {} from e', { i(1, 'RuntimeError("context")') })),
      t('raise'),
      sn(nil, fmt('logger.exception("{}")', { i(1, 'Operation failed') })),
    }),
  })),

  -- tryef: try/except/else/finally
  s('tryef', fmt([[
try:
    {}
except {} as e:
    {}
else:
    {}
finally:
    {}
]], {
    i(1, 'pass'),
    i(2, 'Exception'),
    i(3, 'raise'),
    i(4, '# success path'),
    i(5, '# cleanup'),
  })),

  -- ===========================================================================
  -- Testing (unittest + stdlib)
  -- ===========================================================================

  -- test: pytest-style test function
  s('test', fmt([[
def test_{}() -> None:
    # Arrange
    {}

    # Act
    {} = {}

    # Assert
    assert {} == {}
]], {
    i(1, 'something'),
    i(2, 'input_val = "test"'),
    i(3, 'result'),
    i(4, 'func(input_val)'),
    rep(3),
    i(5, 'expected'),
  })),

  -- testcls: test class
  s('testcls', fmt([[
class Test{}:
    {}def test_{}(self) -> None:
        {}
]], {
    i(1, 'Name'),
    c(2, {
      t(''),
      sn(nil, fmt([[
def setup_method(self) -> None:
        {}

    ]], { i(1, 'self.subject = Name()') })),
    }),
    i(3, 'basic'),
    i(0, 'assert True'),
  })),

  -- fixture: pytest fixture
  s('fix', fmt([[
@pytest.fixture{}
def {}({}){} -> {}:
    {}
]], {
    c(1, { t(''), t('(autouse=True)'), t('(scope="session")'), t('(scope="module")') }),
    i(2, 'resource'),
    i(3),
    c(4, {
      t(''),
      sn(nil, fmt(' -> Generator[{}, None, None]', { i(1, 'Resource') })),
    }),
    c(5, { i(nil, 'Resource'), t('Generator') }),
    c(6, {
      sn(nil, fmt('return {}', { i(1, 'value') })),
      sn(nil, fmt([[
{} = {}
    yield {}
    {}]], {
        i(1, 'resource'),
        i(2, 'acquire()'),
        rep(1),
        i(3, 'resource.close()'),
      })),
    }),
  })),

  -- param: pytest parametrize
  s('param', fmt([[
@pytest.mark.parametrize(
    "{}",
    [
        ({}),
        ({}),
    ],
)
def test_{}({}) -> None:
    {}
]], {
    i(1, 'input_val, expected'),
    i(2, '"hello", 5'),
    i(3, '"world", 5'),
    i(4, 'something'),
    rep(1),
    i(0, 'assert len(input_val) == expected'),
  })),

  -- ===========================================================================
  -- Async patterns (asyncio stdlib)
  -- ===========================================================================

  -- atask: asyncio task group (3.11+)
  s('tg', fmt([[
async with asyncio.TaskGroup() as tg:
    {} = tg.create_task({})
    {} = tg.create_task({})
]], {
    i(1, 'task1'),
    i(2, 'coro1()'),
    i(3, 'task2'),
    i(4, 'coro2()'),
  })),

  -- aq: asyncio.Queue pattern
  s('aq', fmt([[
{}: asyncio.Queue[{}] = asyncio.Queue(maxsize={})

async def producer({}: asyncio.Queue[{}]) -> None:
    await {}.put({})

async def consumer({}: asyncio.Queue[{}]) -> None:
    item = await {}.get()
    {}
    {}.task_done()
]], {
    i(1, 'queue'),
    i(2, 'str'),
    i(3, '0'),
    rep(1),
    rep(2),
    rep(1),
    i(4, 'item'),
    rep(1),
    rep(2),
    rep(1),
    i(5, '# process item'),
    rep(1),
  })),

  -- gather: asyncio.gather
  s('gather', fmt([[
{} = await asyncio.gather(
    {},
    return_exceptions={},
)
]], {
    i(1, 'results'),
    i(2, 'coro1(), coro2()'),
    c(3, { t('False'), t('True') }),
  })),

  -- ===========================================================================
  -- Stdlib patterns
  -- ===========================================================================

  -- log: logging setup
  s('log', fmt([[
import logging

logger = logging.getLogger({})
{}
]], {
    c(1, { t('__name__'), sn(nil, fmt('"{}"', { i(1, 'module') })) }),
    c(2, {
      t(''),
      sn(nil, fmt([[
logging.basicConfig(
    level=logging.{},
    format="%(asctime)s %(name)s %(levelname)s %(message)s",
)]], { c(1, { t('INFO'), t('DEBUG'), t('WARNING') }) })),
    }),
  })),

  -- pathlib: Path operations
  s('path', fmt([[
from pathlib import Path

{} = Path({}){}
]], {
    i(1, 'path'),
    i(2, '__file__'),
    c(3, {
      t('.parent'),
      sn(nil, fmt(' / "{}"', { i(1, 'subdir') })),
      t('.resolve()'),
      t('.parent.parent'),
    }),
  })),

  -- fopen: file open (with statement)
  s('fopen', fmt([[
with open({}, "{}"{}) as {}:
    {} = {}.{}
]], {
    i(1, 'filepath'),
    c(2, { t('r'), t('w'), t('rb'), t('wb'), t('a') }),
    c(3, { t(''), t(', encoding="utf-8"') }),
    i(4, 'f'),
    i(5, 'content'),
    rep(4),
    c(6, { t('read()'), t('readlines()'), t('write(data)') }),
  })),

  -- enum: Enum class
  s('enum', fmt([[
class {}({}):
    {} = {}
    {} = {}
]], {
    i(1, 'Color'),
    c(2, { t('Enum'), t('StrEnum'), t('IntEnum') }),
    i(3, 'RED'),
    i(4, '"red"'),
    i(5, 'BLUE'),
    i(6, '"blue"'),
  })),

  -- main: if __name__ == "__main__"
  s('main', c(1, {
    sn(nil, fmt([[
def main() -> None:
    {}


if __name__ == "__main__":
    main()]], { i(1, 'pass') })),
    sn(nil, fmt([[
async def main() -> None:
    {}


if __name__ == "__main__":
    asyncio.run(main())]], { i(1, 'pass') })),
  })),

  -- cli: argparse skeleton
  s('cli', fmt([[
import argparse

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="{}")
    parser.add_argument("{}", {}{})
    {}
    return parser.parse_args()
]], {
    i(1, 'Description'),
    i(2, 'input'),
    c(3, { t('type=str'), t('type=int'), t('action="store_true"') }),
    c(4, { t(''), sn(nil, fmt(', help="{}"', { i(1, 'help text') })) }),
    i(0),
  })),

  -- comp: list/dict/set comprehension
  s('comp', c(1, {
    sn(nil, fmt('[{} for {} in {}{}]', {
      i(1, 'x'),
      rep(1),
      i(2, 'items'),
      c(3, { t(''), sn(nil, fmt(' if {}', { i(1, 'condition') })) }),
    })),
    sn(nil, fmt('{{{}: {} for {}, {} in {}.items(){}}}', {
      i(1, 'k'),
      i(2, 'v'),
      rep(1),
      rep(2),
      i(3, 'mapping'),
      c(4, { t(''), sn(nil, fmt(' if {}', { i(1, 'condition') })) }),
    })),
    sn(nil, fmt('{{{} for {} in {}{}}}', {
      i(1, 'x'),
      rep(1),
      i(2, 'items'),
      c(3, { t(''), sn(nil, fmt(' if {}', { i(1, 'condition') })) }),
    })),
  })),

  -- slot: __slots__ class (non-dataclass)
  s('slot', fmt([[
class {}:
    __slots__ = ({})

    def __init__(self, {}) -> None:
        {}
]], {
    i(1, 'Name'),
    i(2, '"field",'),
    i(3, 'field: str'),
    i(4, 'self.field = field'),
  })),

  -- proto: Protocol (structural subtyping)
  s('proto', fmt([[
class {}(Protocol):
    def {}(self{}) -> {}:
        ...
]], {
    i(1, 'Readable'),
    i(2, 'read'),
    i(3),
    i(4, 'bytes'),
  })),

}
