import { promises as fs } from 'fs'
import { resolve } from 'path'
const SNIPPET_TOKEN = '--8<-- '

function isLegalIndex(s) {
  // Intended to match empty string, or any positive integer without leading zeros.
  return /^$|^[1-9][0-9]*$/.test(s);
}

function isLegalSectionName(s) {
  // Intended to match a nonemtpy string with a lowercase letter and consisting of lowercase 
  //    letters, hyphen, underline, or numbers.
  return /^[a-z][-_0-9a-z]*$/.test(s);
}

export function parseSnippetPath(snip, spacesAtStart) {
  const str = snip.substring(SNIPPET_TOKEN.length + spacesAtStart)
  let res = { "path": undefined, "beg_line": undefined, "end_line": undefined, "section": undefined }
  if ((str.startsWith('"') && str.endsWith('"')) ||
    (str.startsWith("'") && str.endsWith("'"))) {
    const strs = str.substring(1, str.length - 1).split(":")
    if (strs.length == 1) { // standard
      res.path = strs[0]
    } else if (strs.length == 2 && isLegalSectionName(strs[1])) { // section
      res.path = strs[0]
      res.section = strs[1]
    } else if (
      (strs.length == 2 && isLegalIndex(strs[1]))
      || (strs.length == 3 && isLegalIndex(strs[1]) && isLegalIndex(strs[2]))
    ) { // lines
      res.path = strs[0]
      res.beg_line = strs[1] ? Number(strs[1]) - 1 : undefined
      res.end_line = strs[2] ? Number(strs[2]) : undefined
    }
  }
  if (res.path === undefined || res.beg_line >= res.end_line) {
    throw new SyntaxError(`illegal snippet syntax: ${snip}`)
  }
  return res
}

function extractSection(line, section) {
  const lines = line.split("\n")
  let start_str = `${SNIPPET_TOKEN}[start:${section}]`
  let end_str = `${SNIPPET_TOKEN}[end:${section}]`
  let res = { "beg_line": undefined, "end_line": undefined }
  let start = false
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes(start_str)) {
      if (!start) {
        res.beg_line = i + 1
        start = true
      }
    } else if (lines[i].includes(end_str)) {
      if (start) {
        res.end_line = i
      } else {
        res.beg_line = 0
        res.end_line = 0
      }
      break
    }
  }
  return res
}

async function processSnippetLine (line, root) {
  const spacesAtStart = line.length - line.trimStart().length
  const spaceString = ' '.repeat(spacesAtStart)
  if (line.trim().startsWith(SNIPPET_TOKEN)) {
    const res = parseSnippetPath(line, spacesAtStart, root)
    line = await fs.readFile(resolve(root, res.path), 'utf8')
    if (res.section !== undefined) {
      const line_ids = extractSection(line, res.section)
      if (line_ids.beg_line === undefined) {
        throw new SyntaxError(`cannot find snippet section ${res.section} in file: ${res.path}`)
      }
      res.beg_line = line_ids.beg_line
      res.end_line = line_ids.end_line
    }
    line = line
      .split('\n')
      .slice(res.beg_line, res.end_line)
      .filter((l) => res.section === undefined || !l.includes(SNIPPET_TOKEN))
      .map(l => spaceString + l)
      .join('\n')
  }
  return line
}

export default async function processSnippet (content, root) {
  const res = (await Promise.all(content
    .split('\n')
    .map(async (line) => processSnippetLine(line, root))))
    .join('\n')
  return res
}
