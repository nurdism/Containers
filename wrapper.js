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

const stamp = (pattern, date) => {
  if (typeof pattern !== 'string') {
    date = pattern;
    pattern = 'YYYY-MM-DD';
  }

  if (!date) date = new Date();

  function timestamp() {
    const regex = /(?=(YYYY|YY|MM|DD|HH|mm|ss|ms))\1([:\/]*)/;
    const match = regex.exec(pattern);

    if (match) {
      const increment = method(match[1]);
      const val = '00' + String(date[increment[0]]() + (increment[2] || 0));
      const res = val.slice(-increment[1]) + (match[2] || '');
      pattern = pattern.replace(match[0], res);
      timestamp();
    }
  }

  function method(key) {
    return ({
      YYYY: ['getFullYear', 4],
      YY: ['getFullYear', 2],
      // getMonth is zero-based, thus the extra increment field
      MM: ['getMonth', 2, 1],
      DD: ['getDate', 2],
      HH: ['getHours', 2],
      mm: ['getMinutes', 2],
      ss: ['getSeconds', 2],
      ms: ['getMilliseconds', 3]
    })[key];
  }

  timestamp(pattern);
  return pattern;
};

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
  fs.rename("/home/container/logs/latest.log", `/home/container/logs/${stamp("MM-DD-HH-mm-ss")}.log`, () => {
    process.exit(code);
  })
});

