const spawn = require('child_process').spawn;
const path = require('path');
const cwd = process.cwd();
const fs = require('fs');

fs.access( path.join(cwd, 'Unturned_Headless.x86'), fs.constants.X_OK, (err) => {
  if (err) {
    console.log("Error: 'Unturned_Headless.x86' is not found or is missing permissions to execute!");
    process.exit(1);
  }

  const instance = process.argv[2];
  const logfile = path.join(cwd, `${instance}.console`);

  fs.access(path, fs.constants.F_OK, (err) => {
    if (err) {
      fs.closeSync(fs.openSync(logfile, 'w'));
    }

    const tail = spawn('tail', [logfile]);
    tail.stdout.pipe(process.stdout);

    const unturned = spawn('Unturned_Headless.x86', ['nographics', '-batchmode', `-logfile Servers/${instance}/unturned.log`, `+secureserver/${instance}`]);
    unturned.stdin.setEncoding('utf-8');
    unturned.stdout.pipe(process.stdout);

    process.stdin.setEncoding("utf8");
    process.stdin.on('readable', () => {
      const chunk = process.stdin.read();
      if (chunk !== null) {
        unturned.stdin.write(chunk);
      }
    });

    unturned.on('exit', (code) => {
      process.exit(code);
    });
    unturned.on('close', (code) => {
      process.exit(code);
    });
  });
});