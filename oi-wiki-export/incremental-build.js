'use strict'

const https = require('https');
const util = require("util")
const fs = require('fs').promises
const path = require("path")

// Map doc path to pdf chapters
const PATH_TO_CHAPTER = {
  "intro": 0,
  "contest": 1,
  "tools": 2,
  "lang": 3,
  "basic": 4,
  "search": 5,
  "dp": 6,
  "string": 7,
  "math": 8,
  "ds": 9,
  "graph": 10,
  "geometry": 11,
  "misc": 12,
  "topic": 13
}

/**
 * A wrapper function for fetching the data of changed files in a pull request from GitHub 
 * API using Node built-in `https` module. 
 * The official GitHub API package requires Node v18+,
 * however docker image from https://github.com/OI-wiki/latex-action can only be install with Node v16.
 * @param {*} owner - repository owner
 * @param {*} repo - repository name
 * @param {*} PrNumber - pull request number
 * @param {*} token - GITHUB_TOKEN
 * @returns - JSON data of changed files
 */
async function fetchData(owner, repo, PrNumber, token) {
  const options = {
    method: 'GET',
    headers: {
      'Accept': 'application/vnd.github+json',
      'Authorization': `Bearer ${token}`,
      'X-GitHub-Api-Version': '2022-11-28',
      'User-Agent': 'curl/7.78.0'
    }
  };

  return new Promise((resolve, reject) => {
    const url = `https://api.github.com/repos/${owner}/${repo}/pulls/${PrNumber}/files`;
    let data = '';

    const req = https.request(url, options, (response) => {
      response.on('data', (chunk) => {
        data += chunk;
      });

      response.on('end', () => {
        try {
          const jsonData = JSON.parse(data);
          resolve(jsonData);
        } catch (error) {
          reject(new Error('Error parsing JSON: ' + error.message));
        }
      });
    });

    req.on('error', (error) => {
      reject(new Error(`Error making HTTPS request: ${error.message}`));
    });

    req.end();
  });
}

async function main () {
  if (process.argv.length !== 4) {
    console.log('This script is intended for running on Github Actions.')
    console.log('Usage: node ' + __filename.split('/').pop() + ' ${{ github.ref }} +  ${{ secrets.GITHUB_TOKEN }}')
  }

  const PrNumber = process.argv[2].split("/")[2]
  const token = process.argv[3]
  console.log(`Current PR Number: ${PrNumber}`)

  const data = await fetchData("OI-wiki", "OI-wiki", PrNumber, token)
  
  // error handling
  if (data.map === undefined || data === undefined) {
    console.log(`Error: There is something wrong with the response from GitHub API request.`)
    process.exitCode = -1
    process.exit()
  }

  // const formattedJson = util.inspect(data, {colors: true})
  // console.log(`changed files in JSON format: ${formattedJson}`)
  const changedFiles = data
    .map(item => item.filename) // extract file name from JSON
    .filter(path => path.includes("docs/")) // we only need to detect doc file
    .map(path => path.split("/")[1]) 

  const changedPaths = new Set(changedFiles)  // we only need unique values to determine changed chapters

  // map path to chapter
  const changedChapters = []
  for (const path of changedPaths) {
    if (PATH_TO_CHAPTER[path] !== undefined) {
      changedChapters.push(PATH_TO_CHAPTER[path])
    }
  }

  console.log(`Changed files: ${util.inspect(data.map(item => item.filename), {colors: true})}`)
  console.log(`Changed unique sub paths: ${util.inspect(changedPaths, {colors: true})}`)
  console.log(`Changed chapters: ${util.inspect(changedChapters, {colors: true})}`)

  // wrtie changed chapter to includes.tex
  console.log('Overwriting includes.tex for incremental build...')
  let includes = ''
  for (const id of changedChapters) {
    const texModule = path.join('tex', id.toString())
    includes += '\\input{' + texModule + '}\n' // 输出 includes.tex 章节目录文件
  }
  await fs.writeFile('includes.tex', includes)
  console.log('Complete')
  
  process.exit()
}


main()
