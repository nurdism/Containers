const { exit, Tail } = require('./utility.js');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

const date    = new Date().getTime();

const cwd     = process.cwd();
const args    = process.argv.slice(3);
const exe     = process.argv[2];

const logDir  = `logs`;
const logFile = `rust_${date}.txt`;
const output  = `latest.txt`;

const paths ={
    exe: path.resolve(cwd, exe),
    log: path.join(cwd, logDir, logfile),
    latest: path.join(cwd, logFile, output),
}

if (!fs.existsSync(path.join(cwd, logDir))) {
    fs.mkdirSync(path.join(cwd, logDir));
}

process.stdout.pipe(fs.createWriteStream(paths.latest, { flags: 'a' }));
args.unshift(`-logfile`, `${logDir}/${logFile}`)

fs.access(paths.exe, fs.constants.X_OK, (err) => {
    if (err) exit(`Error: '${exe}' is not found or is missing permissions to execute!`, 1);
    fs.access(paths.log, fs.constants.F_OK, (err) => {
        const log = new Tail(paths.log);
        log.on("line", (data) => {
            console.log(data)
        });

        const server = spawn(paths.exe, args, {cwd, shell: true, stdio: 'inherit'});
        server.on('exit', (code) => {
            exit(`'${exe}' has exited with code ${code}!`, code);
        });
    });
});

