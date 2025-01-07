/* eslint-env mocha */
const assert = require("chai").assert;
const escape = require("./index");

suite("escape-latex", function() {
  test("should escape empty string correctly", function() {
    assert.equal("", escape(""));
  });
  test("should escape casted string correctly", function() {
    assert.equal("1", escape(1));
  });
  test("should escape # correctly", function() {
    assert.equal(
      "Hashtag \\#yolo is all the rage these days \\#twitter",
      escape("Hashtag #yolo is all the rage these days #twitter"),
    );
  });
  test("should escape $ correctly", function() {
    assert.equal("\\$2 is greater than \\$1", escape("$2 is greater than $1"));
  });
  test("should escape % correctly", function() {
    assert.equal(
      "100\\% is 20\\% point greater than 80\\%",
      escape("100% is 20% point greater than 80%"),
    );
  });
  test("should escape & correctly", function() {
    assert.equal(
      "Me \\& you \\& a dog named Boo",
      escape("Me & you & a dog named Boo"),
    );
  });
  test("should escape backlash correctly", function() {
    assert.equal(
      "C:\\textbackslash{} is a good place to format",
      escape("C:\\ is a good place to format"),
    );
  });
  test("should escape { correctly", function() {
    assert.equal(
      "This \\{ does not have an matching bracket",
      escape("This { does not have an matching bracket"),
    );
  });
  test("should escape } correctly", function() {
    assert.equal(
      "There is no opening bracket for this \\}",
      escape("There is no opening bracket for this }"),
    );
  });
  test("should escape ^ correctly", function() {
    assert.equal(
      "2\\textasciicircum{}2\\textasciicircum{}2\\textasciicircum{}2 = 256",
      escape("2^2^2^2 = 256"),
    );
  });
  test("should escape _ correctly", function() {
    assert.equal(
      "\\_ is a shortcut to Underscore, e.g., \\_.each()",
      escape("_ is a shortcut to Underscore, e.g., _.each()"),
    );
  });
  test("should escape ~ correctly", function() {
    assert.equal("pi \\textasciitilde{} 3.1416", escape("pi ~ 3.1416"));
  });
  test("should escape *nix newline correctly", function() {
    assert.equal(
      "\\newline{}\\newline{}",
      escape("\n\n", { preserveFormatting: true }),
    );
  });
  test("should escape Windows newline correctly", function() {
    assert.equal(
      "\\newline{}\\newline{}",
      escape("\r\n\r\n", { preserveFormatting: true }),
    );
  });
  test("should escape mixed newlines correctly", function() {
    assert.equal(
      "\\newline{}\\newline{}\\newline{}\\newline{}",
      escape("\r\n\n\n\r\n", { preserveFormatting: true }),
    );
  });
  test("should escape – (en-dash) correctly", function() {
    assert.equal("\\--", escape("–", { preserveFormatting: true }));
  });
  test("should escape — (em-dash) correctly", function() {
    assert.equal("\\---", escape("—", { preserveFormatting: true }));
  });
  test("should escape spaces correctly", function() {
    assert.equal(
      "Look~ma,~~multiple~spaces",
      escape("Look ma,  multiple spaces", { preserveFormatting: true }),
    );
  });
  test("should escape tabs correctly", function() {
    assert.equal(
      "\\qquad{}\\qquad{}",
      escape("\t\t", { preserveFormatting: true }),
    );
  });
  test("should not preserve formatting by default", function() {
    assert.equal("en dash – is cool", escape("en dash – is cool"));
  });
  test("should not escape - (hyphen)", function() {
    assert.equal("hyphen - is the best", escape("hyphen - is the best"));
  });
  test("should escape customized character correctly", function() {
    const escapeMapFn = (defaultEscapes, formatEscapes) =>
      Object.assign({}, defaultEscapes, formatEscapes, { a: "\\a{}" });
    assert.equal(
      "\\a{} is the first letter",
      escape("a is the first letter", { escapeMapFn }),
    );
  });
  test("stack overflow test", function() {
    // The original algorithm of this library uses recursions to escape
    // the string, which is prone to stack overflow if the input string
    // contains a lot of characters that need to be escaped. This test
    // ensures that we won't run into it in the future.
    const numChars = 100000;
    const originalStr = Array(numChars).join("\\");
    const escapedStr = Array(numChars).join("\\textbackslash{}");
    assert.equal(escapedStr, escape(originalStr));
  });
  test("composite test 1", function() {
    assert.equal(
      "These \\{\\} should be escaped, as well as this \\textbackslash{} character",
      escape("These {} should be escaped, as well as this \\ character"),
    );
  });
});
