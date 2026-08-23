---@type table<string, { description: string, body: string }>
return {
  [";fn"] = {
    description = "Python typed function",
    body = [[def ${1:function_name}(${2:parameter}: ${3:ParameterType}) -> ${4:ReturnType}:
    $0]],
  },
  [";mth"] = {
    description = "Python typed method",
    body = [[def ${1:method_name}(self, ${2:parameter}: ${3:ParameterType}) -> ${4:ReturnType}:
    $0]],
  },
  [";for"] = {
    description = "Python explicitly bounded collection loop",
    body = [[if len(${1:items}) > ${2:items_max}:
    raise ValueError("too many items")
for ${3:item} in ${1:items}:
    $0]],
  },
  [";st"] = {
    description = "Python immutable invariant-bearing data type",
    body = [[@dataclass(frozen=True, slots=True)
class ${1:Type}:
    ${2:value}: ${3:ValueType}

$0]],
  },
  [";newtype"] = {
    description = "Python distinct semantic primitive",
    body = [[${1:Type} = NewType("${1:Type}", ${2:int})
$0]],
  },
  [";enum"] = {
    description = "Python explicit enum",
    body = [[class ${1:Type}(Enum):
    ${2:VALUE} = ${3:"value"}

$0]],
  },
  [";sw"] = {
    description = "Python exhaustive state match",
    body = [[match ${1:state}:
    case ${2:State.VALUE}:
        ${3:handle state}
    case _:
        raise AssertionError("unreachable state")

$0]],
  },
  [";err"] = {
    description = "Python chained operating error",
    body = [[try:
    ${1:result} = ${2:operation}
except ${3:OperatingError} as error:
    raise ${4:DomainError}("${5:operation failed}") from error

$0]],
  },
  [";parse"] = {
    description = "Python bounded parser constructor",
    body = [[@classmethod
def parse(cls, raw: str) -> Self:
    if len(raw) == 0:
        raise ValueError("empty value")
    if len(raw) > ${1:raw_length_max}:
        raise ValueError("value exceeds maximum length")
    if ${2:invalid condition}:
        raise ValueError("${3:invalid value}")

    ${4:value} = ${5:parse raw}
    return cls(${4:value}=${4:value})]],
  },
  [";batch"] = {
    description = "Python explicitly bounded batch",
    body = [[if len(${1:inputs}) > ${2:batch_count_max}:
    raise ValueError("batch exceeds maximum size")
${3:outputs} = [${4:process_input}(input_value) for input_value in ${1:inputs}]

$0]],
  },
  [";with"] = {
    description = "Python explicitly owned resource scope",
    body = [[with ${1:open_resource()} as ${2:resource}:
    $0]],
  },
  [";test"] = {
    description = "Python tests covering valid, boundary, and invalid inputs",
    body = [[def test_${1:name}_valid() -> None:
    ${2:test valid input}


def test_${1:name}_boundary() -> None:
    ${3:test boundary input}


def test_${1:name}_invalid() -> None:
    ${4:test invalid input}
]],
  },
}
