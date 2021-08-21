import http from 'http'
`
USAGE:
npm i mathjax-full
node -r esm index.js
curl "127.0.0.1:8888/svg.latex?%5Cbegin%7Bmatrix%7D%2023%26%20232%20%2644%20%5C%5C%2023%26%20333%20%26%20aseasda%20%5Cend%7Bmatrix%7D" > res.svg
curl 127.0.0.1:8888/svg.latex?encodeURIComponent(equation)
`
const PACKAGES = 'base, autoload, require, ams, newcommand';
const CSS = [
  'svg a{fill:blue;stroke:blue}',
  '[data-mml-node="merror"]>g{fill:red;stroke:red}',
  '[data-mml-node="merror"]>rect[data-background]{fill:yellow;stroke:none}',
  '[data-frame],[data-line]{stroke-width:70px;fill:none}',
  '.mjx-dashed{stroke-dasharray:140}',
  '.mjx-dotted{stroke-linecap:round;stroke-dasharray:0,140}',
  'use[data-c]{stroke-width:3px}'
].join('');
require('mathjax-full').init({
    options: {
        enableAssistiveMml: false
    },
    loader: {
        source: (require('mathjax-full/components/src/source.js').source),
        load: ['adaptors/liteDOM', 'tex-svg']
    },
    tex: {
        packages: PACKAGES.split(/\s*,\s*/)
    },
    svg: {
        fontCache: 'local'
    },
    startup: {
        typeset: false
    }
}).then((MathJax) => {
    http.createServer(async function (request, response) {
        console.log(request.url)
        if (request.url.match("png")) {
            response.writeHead(200, {'Content-Type': 'image/png'});
            response.end("wtf")
        } else if (request.url.match("svg")) {
            response.writeHead(200, {'Content-Type': 'image/svg+xml'});
        } else {
            response.writeHead(503)
            response.end("wtf")
        }

        let equation = decodeURIComponent(request.url.split('?')[1])
        console.log(equation)
        try {
            let node = await MathJax.tex2svgPromise(equation, {
                display: true,
            })
            const adaptor = MathJax.startup.adaptor;
            let html = adaptor.innerHTML(node)
            response.end(html.replace(/<defs>/, `<defs><style>${CSS}</style>`));
        } catch (e) {
            console.log(e);
            response.end("err")
        }
    }).listen(8888);
    
    console.log('Server running at http://127.0.0.1:8888/');

})
