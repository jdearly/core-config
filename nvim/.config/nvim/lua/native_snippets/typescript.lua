---@type table<string, { description: string, body: string }>
return {
  [";fn"] = {
    description = "TypeScript typed function returning a result value",
    body = [[function ${1:functionName}(
  ${2:parameters},
): Result<${3:ReturnType}, ${4:DomainError}> {
  $0
}]],
  },
  [";afn"] = {
    description = "TypeScript typed async function returning a result value",
    body = [[async function ${1:functionName}(
  ${2:parameters},
): Promise<Result<${3:ReturnType}, ${4:DomainError}>> {
  $0
}]],
  },
  [";for"] = {
    description = "TypeScript explicitly bounded collection loop",
    body = [[if (${1:items}.length > ${2:itemsMax}) {
  return {
    kind: "failure",
    failure: new RangeError("too many items"),
  };
}
for (const ${3:item} of ${1:items}) {
  $0
}]],
  },
  [";st"] = {
    description = "TypeScript readonly invariant-bearing data type",
    body = [[type ${1:Type} = {
  readonly ${2:value}: ${3:ValueType};
};

$0]],
  },
  [";iface"] = {
    description = "TypeScript interface for a justified implementation seam",
    body = [[interface ${1:Name} {
  ${2:method}(${3:parameters}): Result<${4:ReturnType}, ${5:DomainError}>;
}

$0]],
  },
  [";result"] = {
    description = "TypeScript explicit success or failure result",
    body = [[type ${1:Result}<Value, Failure> =
  | { readonly kind: "success"; readonly value: Value }
  | { readonly kind: "failure"; readonly failure: Failure };

$0]],
  },
  [";union"] = {
    description = "TypeScript closed discriminated union",
    body = [[type ${1:State} =
  | { readonly kind: "${2:idle}" }
  | { readonly kind: "${3:active}"; readonly ${4:value}: ${5:ValueType} };

$0]],
  },
  [";sw"] = {
    description = "TypeScript exhaustive discriminated-union switch",
    body = [[switch (${1:value}.kind) {
  case "${2:case}": {
    ${3:handle case}
    break;
  }
  default: {
    const unreachable: never = ${1:value};
    return unreachable;
  }
}

$0]],
  },
  [";err"] = {
    description = "TypeScript checked operating error value",
    body = [[const ${1:result} = ${2:operation};
if (${1:result}.kind === "failure") {
  return ${1:result};
}
const ${3:value} = ${1:result}.value;

$0]],
  },
  [";brand"] = {
    description = "TypeScript opaque semantic string type",
    body = [[declare const ${1:type}Brand: unique symbol;
type ${2:Type} = string & { readonly [${1:type}Brand]: true };

$0]],
  },
  [";parse"] = {
    description = "TypeScript bounded parser from unknown to an opaque type",
    body = [[function parse${1:Type}(
  input: unknown,
): Result<${1:Type}, ${2:ParseError}> {
  if (typeof input !== "string") {
    return { kind: "failure", failure: new ${2:ParseError}("expected string") };
  }
  if (input.length === 0) {
    return { kind: "failure", failure: new ${2:ParseError}("empty value") };
  }
  if (input.length > ${3:valueLengthMax}) {
    return { kind: "failure", failure: new ${2:ParseError}("value too long") };
  }

  // These checks establish the invariant at the sole construction boundary.
  return { kind: "success", value: input as ${1:Type} };
}]],
  },
  [";batch"] = {
    description = "TypeScript explicitly bounded asynchronous batch",
    body = [[if (${1:inputs}.length > ${2:batchMax}) {
  return {
    kind: "failure",
    failure: new RangeError("batch exceeds maximum size"),
  };
}
const ${3:results} = await Promise.all(
  ${1:inputs}.map((${4:input}) => ${5:processInput}(${4:input})),
);

$0]],
  },
  [";test"] = {
    description = "TypeScript tests covering valid, boundary, and invalid inputs",
    body = [[test("${1:name}: valid", () => {
  ${2:test valid input}
});

test("${1:name}: boundary", () => {
  ${3:test boundary input}
});

test("${1:name}: invalid", () => {
  ${4:test invalid input}
});]],
  },
}
