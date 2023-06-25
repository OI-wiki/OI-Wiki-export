"use strict";
var remark = require("remark");
var parse = require("remark-parse");
var math = require("/home/ir1d/Documents/repo/OI-wiki/node_modules/remark-math/index.js");
var sp = require("/home/ir1d/Documents/repo/OI-wiki/node_modules/remark-math-space/index.js");
var de = require("./index.js");
// var de = require("remark-details");


var fs = require("fs");
var www = fs.readFileSync("a.md");

// const doc = "中文abc中文$a_i$中文";
remark()
  .use(parse)
  .use(math)
  .use(de)
  .use(sp)
  .process(www, function(err, res) {
    console.log(String(res));
  });
