---@type table<string, { description: string, body: string }>
return {
  [";fn"] = {
    description = "C typed function with an explicit programmer contract",
    body = [[${1:static} ${2:void}
${3:function_name}(${4:void})
{
    ASSERT(${5:precondition});
    $0
}]],
  },
  [";for"] = {
    description = "C explicitly bounded collection loop",
    body = [[ASSERT(${1:items} != NULL);
ASSERT(${2:item_count} <= ${3:item_count_max});
for (size_t ${4:item_index} = 0; ${4:item_index} < ${2:item_count}; ++${4:item_index}) {
    $0
}]],
  },
  [";st"] = {
    description = "C invariant-bearing distinct data type",
    body = [[typedef struct ${1:Type} {
    ${2:fields}
} ${1:Type};

$0]],
  },
  [";sw"] = {
    description = "C exhaustive state switch",
    body = [[switch (${1:state}) {
case ${2:STATE_VALUE}:
    ${3:handle state;}
    break;
default:
    ASSERT(false);
    ${4:return STATE_RESULT_INVALID;}
}

$0]],
  },
  [";err"] = {
    description = "C checked operating error",
    body = [[${1:OperationResult} ${2:operation_result} = ${3:operation};
if (${2:operation_result} != ${4:OPERATION_RESULT_OK}) {
    return ${2:operation_result};
}

$0]],
  },
  [";parse"] = {
    description = "C bounded parser with paired output contracts",
    body = [[static ${1:ParseResult}
${2:type_parse}(
    const uint8_t *input,
    size_t input_size_bytes,
    ${3:Type} *out
)
{
    ASSERT(input != NULL);
    ASSERT(out != NULL);
    if (input_size_bytes > ${4:input_size_bytes_max}) {
        return ${5:PARSE_RESULT_INPUT_TOO_LARGE};
    }

    ${3:Type} parsed = {0};
    ${6:parse input into parsed}
    ASSERT(${7:type_valid(&parsed)});
    *out = parsed;
    ASSERT(${8:type_valid(out)});
    return ${9:PARSE_RESULT_OK};
}]],
  },
  [";batch"] = {
    description = "C bounded batch with caller-owned output storage",
    body = [[static ${1:BatchResult}
${2:process_batch}(
    const ${3:Input} *inputs,
    size_t input_count,
    ${4:Output} *outputs,
    size_t output_capacity
)
{
    ASSERT(inputs != NULL);
    ASSERT(outputs != NULL);
    if (input_count > ${5:batch_count_max}) {
        return ${6:BATCH_RESULT_TOO_LARGE};
    }
    if (input_count > output_capacity) {
        return ${7:BATCH_RESULT_CAPACITY_EXHAUSTED};
    }

    for (size_t input_index = 0; input_index < input_count; ++input_index) {
        ${1:BatchResult} batch_result =
            ${8:process_one}(&inputs[input_index], &outputs[input_index]);
        if (batch_result != ${9:BATCH_RESULT_OK}) {
            return batch_result;
        }
    }
    return ${9:BATCH_RESULT_OK};
}]],
  },
  [";test"] = {
    description = "C test covering valid, boundary, and invalid inputs",
    body = [[static void
${1:test_name}(void)
{
    ${2:TEST_ASSERT(valid input);}
    ${3:TEST_ASSERT(boundary input);}
    ${4:TEST_ASSERT(invalid input);}
}]],
  },
}
