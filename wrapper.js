const { spawn } = require('child_process');
const path = require('path');
const cwd = process.cwd();
const fs = require('fs');

const port = parseInt(process.argv[2]);

if ( port && port > 0) {
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
    }).listen(port, () => { console.log(`Webserver listening on port: ${port}`) });
}

let exe = process.argv[3];
let args = process.argv.slice(4, process.argv.length).map( (arg, i, a) => {
  if (( arg.startsWith("-") || arg.startsWith("+"))) {
    if( a[i+1].startsWith("-") || a[i+1].startsWith("+")){
      return arg
    }else{
      return `${arg} ${a[i+1]}`
    }
  }
}).filter((n) => n != undefined);

const gmod = spawn(exe, args, { cwd, shell: true, stdio: 'inherit' });
gmod.on('exit', (code) => {
  process.exit(code);
});

