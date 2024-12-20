"use strict";

// Map the characters to escape to their escaped values. The list is derived
// from http://www.cespedes.org/blog/85/how-to-escape-latex-special-characters
const defaultEscapes = {
  "{": "\\{",
  "}": "\\}",
  "#": "\\#",
  "[": "\\[",
  "]": "\\]",
  "(": "\\(",
  ")": "\\)",
  "*": "\\*",
  "_": "\\_",
  "`": "\\`",
  "<": "\\<",
  ">": "\\>",
  "@": "\\@",
  "=": "\\=",
  "-": "\\-",
  "+": "\\+",
  "/": "\\/",
  "$": "\\$",
  "\\": "\\\\",
  "\"": "\\\"",
  "~": "\\~",
  ".": "\\.",
};
const formatEscapes = {
  "\u2013": "\\--",
  "\u2014": "\\---",
  " ": "~",
  "\t": "\\qquad{}",
  "\r\n": "\\newline{}",
  "\n": "\\newline{}",
};

const defaultEscapeMapFn = (defaultEscapes, formatEscapes) =>
  Object.assign({}, defaultEscapes, formatEscapes);

/**
 * Escape a string to be used in Typst documents.
 * @param {string} str the string to be escaped.
 * @param {boolean} params.preserveFormatting whether formatting escapes should
 *  be performed (default: false).
 * @param {function} params.escapeMapFn the function to modify the escape maps.
 * @return {string} the escaped string, ready to be used in Typst.
 */
module.exports = function(
  str,
  { preserveFormatting = false, escapeMapFn = defaultEscapeMapFn } = {},
) {
  let runningStr = String(str);
  let result = "";

  const escapes = escapeMapFn(
    Object.assign({}, defaultEscapes),
    preserveFormatting ? Object.assign({}, formatEscapes) : {},
  );
  const escapeKeys = Object.keys(escapes); // as it is reused later on

  // Algorithm: Go through the string character by character, if it matches
  // with one of the special characters then we'll replace it with the escaped
  // version.
  while (runningStr) {
    let specialCharFound = false;
    escapeKeys.forEach(function(key, index) {
      if (specialCharFound) {
        return;
      }
      if (
        runningStr.length >= key.length &&
        runningStr.slice(0, key.length) === key
      ) {
        result += escapes[escapeKeys[index]];
        runningStr = runningStr.slice(key.length, runningStr.length);
        specialCharFound = true;
      }
    });
    if (!specialCharFound) {
      result += runningStr.slice(0, 1);
      runningStr = runningStr.slice(1, runningStr.length);
    }
  }
  return result;
};
