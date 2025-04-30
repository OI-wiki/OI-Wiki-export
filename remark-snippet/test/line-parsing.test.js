'use strict'
import test from 'ava'
import { parseSnippetPath } from "../parser.js"

async function test_case (case_info, snippet, expected) {
  test (case_info, async t => {
    const output = parseSnippetPath(snippet, 0)
    t.deepEqual(output, expected)
  })
}

async function test_error (case_info, snippet, error_message) {
  test (case_info, async t => {
    const error = t.throws(() => {
      parseSnippetPath(snippet, 0)
    }, { instanceOf : SyntaxError })
    t.is(error.message, error_message)
  })  
}

test_case (
  "standard format",
  "--8<-- 'codes/example.txt'",
  { "path": "codes/example.txt", "beg_line": undefined, "end_line": undefined, "section": undefined }
)

test_case (
  "lines format: both indices",
  "--8<-- 'codes/example.txt:10:15'",
  { "path": "codes/example.txt", "beg_line": 9, "end_line": 15, "section": undefined }
)

test_case (
  "lines format: starting index only (1)",
  "--8<-- 'codes/example.txt:10'",
  { "path": "codes/example.txt", "beg_line": 9, "end_line": undefined, "section": undefined }
)

test_case (
  "lines format: starting index only (2)",
  "--8<-- 'codes/example.txt:10:'",
  { "path": "codes/example.txt", "beg_line": 9, "end_line": undefined, "section": undefined }
)

test_case (
  "lines format: ending index only",
  "--8<-- 'codes/example.txt::15'",
  { "path": "codes/example.txt", "beg_line": undefined, "end_line": 15, "section": undefined }
)

test_case (
  "lines format: no index (1)",
  "--8<-- 'codes/example.txt::'",
  { "path": "codes/example.txt", "beg_line": undefined, "end_line": undefined, "section": undefined }
)

test_case (
  "lines format: no index (2)",
  "--8<-- 'codes/example.txt:'",
  { "path": "codes/example.txt", "beg_line": undefined, "end_line": undefined, "section": undefined }
)

test_case (
  "section format",
  "--8<-- 'codes/example.txt:main'",
  { "path": "codes/example.txt", "beg_line": undefined, "end_line": undefined, "section": "main" }
)

test_error (
  "error: wrong snippet marker",
  "-8<-- 'codes/example.txt:2:10'",
  "illegal snippet syntax: -8<-- 'codes/example.txt:2:10'"
)

test_error (
  "error: unmatched quotes",
  "--8<-- 'codes/example.txt:2:10",
  "illegal snippet syntax: --8<-- 'codes/example.txt:2:10"
)

test_error (
  "error: too many colons",
  "--8<-- 'codes/example.txt:3:2:10'",
  "illegal snippet syntax: --8<-- 'codes/example.txt:3:2:10'"
)

test_error (
  "error: zero line index",
  "--8<-- 'codes/example.txt:0:2'",
  "illegal snippet syntax: --8<-- 'codes/example.txt:0:2'"
)

test_error (
  "error: negative line index",
  "--8<-- 'codes/example.txt:3:-2'",
  "illegal snippet syntax: --8<-- 'codes/example.txt:3:-2'"
)

test_error (
  "error: beg_line > end_line (1)",
  "--8<-- 'codes/example.txt:4:3'",
  "illegal snippet syntax: --8<-- 'codes/example.txt:4:3'"
)

test_error (
  "error: beg_line > end_line (2)",
  "--8<-- 'codes/example.txt:4:2'",
  "illegal snippet syntax: --8<-- 'codes/example.txt:4:2'"
)

test_error (
  "error: illegal character in section name (1)",
  "--8<-- 'codes/example.txt:foo:1'",
  "illegal snippet syntax: --8<-- 'codes/example.txt:foo:1'"
)

test_error (
  "error: illegal character in section name (2)",
  "--8<-- 'codes/example.txt:foo:bar'",
  "illegal snippet syntax: --8<-- 'codes/example.txt:foo:bar'"
)

test_error (
  "error: illegal character in section name (3)",
  "--8<-- 'codes/example.txt:Foo'",
  "illegal snippet syntax: --8<-- 'codes/example.txt:Foo'"
)

test_error (
  "error: illegal character in section name (4)",
  "--8<-- 'codes/example.txt:_foo'",
  "illegal snippet syntax: --8<-- 'codes/example.txt:_foo'"
)

test_error (
  "error: multiple lines format",
  "--8<-- 'codes/example.txt:1,2:3'",
  "illegal snippet syntax: --8<-- 'codes/example.txt:1,2:3'"
)
