const { spawn } = require('child_process');
const path = require('path');
const cwd = process.cwd();
const fs = require('fs');

const port = parseInt(process.argv[2]);

if ( port && port > 0) {
  require('http')
    .createServer((req, res) => {

      const file = path.join(cwd, 'fastdl', req['url']);

      if(!fs.existsSync(file)){
        res.writeHead(404, {'Content-type':'Content-Type: text/html; charset=utf-8'});
        res.write('<!DOCTYPE html><html><body><h1>File not found!</h1></body></html>');
        res.end();
      }

      if (req.headers['range']) {
        const stat = fs.statSync(file);
        const range = req.headers.range;
        const total = stat.size;
        const parts = range.replace(/bytes=/, "").split("-");

        const start = parseInt(parts[0], 10);
        const end = parts[1] ? parseInt(parts[1], 10) : total-1;

        res.writeHead(206, {
          'content-range': 'bytes ' + start + '-' + end + '/' + total,
          'accept-ranges': 'bytes',
          'content-length': (end-start) +1,
          'content-type': ''
        });

        fs.createReadStream(file, {start: start, end: end}).pipe(res);
      }else{
        fs.readFile(file, (err, data) => {
          if (err) {
            res.writeHead(404, {'Content-type':'Content-Type: text/html; charset=utf-8'});
            res.write('<!DOCTYPE html><html><body><h1>File not found!</h1></body></html>');
            res.end();
          } else {
            const ext = /(?:\.([^.]+))?$/.exec(req['url'])[1];
            let content = 'Content-Type: application/x-bzip2';
            if(ext !== 'bz2'){
              content = 'Content-Type: text/html; charset=utf-8';
            }
            res.writeHead(200, {'Content-type': content});
            res.write(data);
            res.end();
          }
        });
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

