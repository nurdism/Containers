const { spawn, fork } = require('child_process');
const cwd = process.cwd();
const fs = require('fs');
process.env.PORT = parseInt(process.argv[2]);

const setup = () => {
  let http = fork('/http.js', [], { cwd: cwd, env: process.env} );
  http.on('message', (m) => {
    console.log('HTTP:', m);
  });
  http.on('close', (code) => {
    if ( code === 1 ) {
      console.log('HTTP: CRASHED!');
      setup();
    }
  });
};

setup();

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

