const { spawn } = require('child_process');
const path = require('path');
const cwd = process.cwd();
const fs = require('fs');

const port = parseInt(process.argv[2]);

if ( port && port > 0) {
  require('http')
    .createServer((req, res) => {

      const file = path.join(cwd, 'fastdl', req['url']);
      const ext = /(?:\.([^.]+))?$/.exec(req['url'])[1];

      if(!fs.existsSync(file)){
        res.writeHead(404, {'content-type':'text/html; charset=utf-8'});
        res.write('<!DOCTYPE html><html><body><h1>File not found!</h1></body></html>');
        res.end();
      }else{
        if(ext !== 'bz2'){
          fs.readFile(file, (err, data) => {
            res.writeHead(200, {'content-type': 'text/html; charset=utf-8'});
            res.write(data);
            res.end();
          });
        }else{
          const stat = fs.statSync(file);
          const size = stat.size;
          res.writeHead(200, {
            'accept-ranges': 'bytes',
            'content-length': size,
            'content-type': 'application/octet-stream'
          });
          fs.createReadStream(file).pipe(res);
        }
      }
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

