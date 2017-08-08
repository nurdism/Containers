const { spawn } = require('child_process');
const path = require('path');
const cwd = process.cwd();
const fs = require('fs');

const port = process.argv[2];
require('http')
  .createServer((req, res) => {
    fs.readFile(path.join(cwd, 'fastdl', req['url']), (err, data) => {
      if (err) {
        res.writeHead(404);
        res.end("<!DOCTYPE html><html><body><h1>File not found!</h1></body></html>");
        return;
      }
      res.writeHead(200);
      res.end(data);
    });
}).listen(port);

const gmod = spawn( process.argv[3], process.argv.slice(3, process.argv.length));
gmod.stdin.setEncoding('utf-8');
gmod.stdout.pipe(process.stdout);

process.stdin.setEncoding("utf8");
process.stdin.on('readable', () => {
  const chunk = process.stdin.read();
  if (chunk !== null) {
    gmod.stdin.write(chunk);
  }
});

gmod.on('exit', (code) => {
  process.exit(code);
});


