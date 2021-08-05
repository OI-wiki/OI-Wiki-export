const glob = require('tiny-glob')
const fs = require('fs').promises
const path = require('path')
const SNIPPET_TOKEN = '--8<-- '

let oi_wiki_root = '.'

function resolvePath (snip) {
  let str = snip.substring(SNIPPET_TOKEN.length)
  if ((str.startsWith('"') && str.endsWith('"')) ||
    (str.startsWith("'") && str.endsWith("'"))) {
    str = str.substring(1, str.length - 1)
  } else {
    console.error('cannot parse snippet:', snip)
  }
  return path.resolve(oi_wiki_root, str)
}

async function process_snippet (file) {
  const content = await fs.readFile(file, 'utf8')
  const res = (await Promise.all(content
    .split('\n')
    .map(async (line) => {
      const spacesAtStart = line.length - line.trimLeft().length
      const spaceString = ' '.repeat(spacesAtStart)
      if (line.trim().startsWith(SNIPPET_TOKEN)) {
        const res = resolvePath(line)
        line = await fs.readFile(res, 'utf8')
      }
      line = spaceString + line
      return line
    })))
    .join('\n')
  await fs.writeFile(file, res)
}

module.exports = {}
module.exports.snippet = async function snippet (root) {
  oi_wiki_root = root
  const files = await glob(`${path.resolve(root)}/**/*.md`)
  await Promise.all(files.map(process_snippet))
}
