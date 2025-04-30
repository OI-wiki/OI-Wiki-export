'use strict'
import test from 'ava'
import processSnippet from "../parser.js"

async function test_case (case_info, input, expected) {
  test (case_info, async t => {
    const output = await processSnippet(input, '.')
    t.is(output, expected)
  })
}

async function test_error (case_info, input, error_message) {
  test (case_info, async t => {
    const error = await t.throwsAsync(() => {
      return processSnippet(input, '.')
    }, { instanceOf : SyntaxError })
    t.is(error.message, error_message)
  })  
}

test_case (
  'basic test',
  '--8<-- "codes/example.txt"',
`% --8<-- [start:full-text]
/* --8<-- [start:chapter-one] */
Once upon a time, there was a programmer.
    They wrote code every day.
    If the code worked:
        They would smile and drink coffee.
        They might even share it online.
    Else:
        They would debug for hours.
            Sometimes, they would scream internally.
    Eventually, the program ran flawlessly.
The end of chapter one.

# --8<-- [start:chapter-two-three]
/* --8<-- [end:chapter-one] */
// --8<-- [end:chapter-four]
// --8<-- [start:chapter-two]
In a faraway land, a designer opened their favorite tool.
    They sketched ideas with care and precision.
    If the client approved:
        The designer would celebrate with a walk.
    Else:
// --8<-- [start:chapter-two]
        They would revise tirelessly.
            Colors changed. Shapes shifted.
    In time, the perfect design emerged.
The end of chapter two.

// --8<-- [end:chapter-two]
# --8<-- [start:chapter-three]
Late at night, a writer stared at a blinking cursor.
    They typed a sentence, then deleted it.
    If inspiration struck:
        Words flowed like a river.
            Paragraphs stacked into pages.
// --8<-- [start:chapter-two]
    Else:
        The cursor blinked in silence.
    But eventually, the story found its voice.
The end of chapter three.

# --8<-- [end:chapter-three]
% --8<-- [end:full-text]
// --8<-- [end:chapter-two]
// --8<-- [start:chapter-four]
`
)

test_case (
  'section test: comment style 1',
  '--8<-- "codes/example.txt:chapter-one"',
`Once upon a time, there was a programmer.
    They wrote code every day.
    If the code worked:
        They would smile and drink coffee.
        They might even share it online.
    Else:
        They would debug for hours.
            Sometimes, they would scream internally.
    Eventually, the program ran flawlessly.
The end of chapter one.
`
)

test_case (
  'section test: comment style 2 + multiple start and end',
  '--8<-- "codes/example.txt:chapter-two"',
`In a faraway land, a designer opened their favorite tool.
    They sketched ideas with care and precision.
    If the client approved:
        The designer would celebrate with a walk.
    Else:
        They would revise tirelessly.
            Colors changed. Shapes shifted.
    In time, the perfect design emerged.
The end of chapter two.
`
)

test_case (
  'section test: comment style 3',
  '--8<-- "codes/example.txt:chapter-three"',
`Late at night, a writer stared at a blinking cursor.
    They typed a sentence, then deleted it.
    If inspiration struck:
        Words flowed like a river.
            Paragraphs stacked into pages.
    Else:
        The cursor blinked in silence.
    But eventually, the story found its voice.
The end of chapter three.
`
)

test_case (
  'section test: end before start',
  '--8<-- "codes/example.txt:chapter-four"',
``
)

test_case (
    'section test: only start, no end',
    '--8<-- "codes/example.txt:chapter-two-three"',
`In a faraway land, a designer opened their favorite tool.
    They sketched ideas with care and precision.
    If the client approved:
        The designer would celebrate with a walk.
    Else:
        They would revise tirelessly.
            Colors changed. Shapes shifted.
    In time, the perfect design emerged.
The end of chapter two.

Late at night, a writer stared at a blinking cursor.
    They typed a sentence, then deleted it.
    If inspiration struck:
        Words flowed like a river.
            Paragraphs stacked into pages.
    Else:
        The cursor blinked in silence.
    But eventually, the story found its voice.
The end of chapter three.

`
  )

test_case (
  'lines test: standard format',
  '--8<-- "codes/example.txt:5:10"',
`    If the code worked:
        They would smile and drink coffee.
        They might even share it online.
    Else:
        They would debug for hours.
            Sometimes, they would scream internally.`
)

test_case (
  'lines test: without start index',
  '--8<-- "codes/example.txt::5"',
`% --8<-- [start:full-text]
/* --8<-- [start:chapter-one] */
Once upon a time, there was a programmer.
    They wrote code every day.
    If the code worked:`
)

test_case (
  'lines test: without end index (type 1)',
  '--8<-- "codes/example.txt:37:"',
`    Else:
        The cursor blinked in silence.
    But eventually, the story found its voice.
The end of chapter three.

# --8<-- [end:chapter-three]
% --8<-- [end:full-text]
// --8<-- [end:chapter-two]
// --8<-- [start:chapter-four]
`
)

test_case (
  'lines test: without end index (type 2)',
  '--8<-- "codes/example.txt:37"',
`    Else:
        The cursor blinked in silence.
    But eventually, the story found its voice.
The end of chapter three.

# --8<-- [end:chapter-three]
% --8<-- [end:full-text]
// --8<-- [end:chapter-two]
// --8<-- [start:chapter-four]
`
)

test_case (
  'extra space test',
`    --8<-- "codes/example.txt:chapter-one"
        --8<-- "codes/example.txt:chapter-two"`,
`    Once upon a time, there was a programmer.
        They wrote code every day.
        If the code worked:
            They would smile and drink coffee.
            They might even share it online.
        Else:
            They would debug for hours.
                Sometimes, they would scream internally.
        Eventually, the program ran flawlessly.
    The end of chapter one.
    
        In a faraway land, a designer opened their favorite tool.
            They sketched ideas with care and precision.
            If the client approved:
                The designer would celebrate with a walk.
            Else:
                They would revise tirelessly.
                    Colors changed. Shapes shifted.
            In time, the perfect design emerged.
        The end of chapter two.
        `
)

test_error (
  'error: section not found',
  '--8<-- "codes/example.txt:chapter-five"',
  'cannot find snippet section chapter-five in file: codes/example.txt'
)
