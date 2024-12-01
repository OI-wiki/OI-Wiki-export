import glob from 'tiny-glob'
import { promises as fs } from 'fs'
import { resolve } from 'path'
const SNIPPET_TOKEN = '--8<-- '
const snippetRegEx = /^("|')(.*?)(:(\d+):(\d+))?\1$/

let oi_wiki_root = '.'

function resolvePath(snip, spacesAtStart) {
  const str = snip.substring(SNIPPET_TOKEN.length + spacesAtStart)
  const matches = snippetRegEx.exec(str)
  let res = {
    "path": str,
    "beg_line": undefined,
    "end_line": undefined,
  }
  if (matches === null || matches[2] === undefined) {
    console.error("cannot parse snippet:", snip)
  } else {
    res.path = matches[2];
    if (matches[3] !== undefined) {
      res.beg_line = Number(matches[4]) - 1
      res.end_line = Number(matches[5])
    }
  }
  res.path = resolve(oi_wiki_root, res.path)
  return res
}

async function process_snippet (file) {
  const content = await fs.readFile(file, 'utf8')
  const res = (await Promise.all(content
    .split('\n')
    .map(async (line) => {
      const spacesAtStart = line.length - line.trimLeft().length
      const spaceString = ' '.repeat(spacesAtStart)
      if (line.trim().startsWith(SNIPPET_TOKEN)) {
        const res = resolvePath(line, spacesAtStart)
        line = await fs.readFile(res.path, 'utf8')
        line = line.split('\n').slice(res.beg_line, res.end_line).map(l => spaceString + l).join('\n')
      }
      return line
    })))
    .join('\n')
  await fs.writeFile(file, res)
}


export async function snippet (root) {
  oi_wiki_root = root
  const files = await glob(`${resolve(root)}/**/*.md`)
  await Promise.all(files.map(process_snippet))
}
