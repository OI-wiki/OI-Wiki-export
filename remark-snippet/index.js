import glob from 'tiny-glob'
import { promises as fs } from 'fs'
import { resolve } from 'path'
import processSnippet from './parser.js'

async function processSnippetFile (file, root) {
  const content = await fs.readFile(file, 'utf8')
  const res = await processSnippet(content, root)
  await fs.writeFile(file, res)
}

export default async function snippet (root) {
  const files = await glob(`${resolve(root)}/**/*.md`)
  await Promise.all(files.map(file => processSnippetFile(file, root)))
}
