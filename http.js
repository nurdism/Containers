const path = require('path');
const cwd = process.cwd();
const fs = require('fs');

if ( process.env.PORT && process.env.PORT > 0) {
  require('http')
    .createServer((req, res) => {
      const file = path.join(cwd, 'fastdl', req['url']);
      const ext = /(?:\.([^.]+))?$/.exec(req['url'])[1];
      try {
        if(!fs.existsSync(file)){
          res.writeHead(404, {'content-type':'text/html; charset=utf-8'});
          res.write('<!DOCTYPE html><html><body><h1>File not found!</h1></body></html>');
          res.end();
        }else{
          if(ext !== 'bz2'){
            fs.readFile(file, (err, data) => {
              if (err) {
                process.send(err);
                return;
              }
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
      } catch (e) {
        process.send(e);
      }
    }).listen(process.env.PORT, () => { process.send(`Web server listening on port: ${process.env.PORT}`) });
}else{
  process.send("Port not set!");
  process.exit(0);
}

process.on('uncaughtException', (err) => {
  process.send(err);
  process.exit(1);
});