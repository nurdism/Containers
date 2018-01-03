const { EventEmitter } = require('events')
const { spawn } = require('child_process')
const WebSocket = require('ws')
const path = require('path')
const fs = require('fs')

const logDir  = 'logs'
const logFile = `rust_${new Date().getTime()}.txt`

const input   = process.argv[2].split(' ')
const cwd     = process.cwd()
const args    = input.slice(1).concat(['-logfile', `${logDir}/${logFile}`])
const exe     = input[0]

const paths ={
    exe: path.resolve(cwd, exe),
    log: path.join(cwd, logDir, logFile),
    latest: path.join(cwd, logDir, 'latest.txt')
}

function stamp(pattern, date) {
    if (typeof pattern !== 'string') {
      date = pattern
      pattern = 'YYYY-MM-DD'
    }

    if (!date) date = new Date()

    function timestamp() {
      const regex = /(?=(YYYY|YY|MM|DD|HH|mm|ss|ms))\1([:\/]*)/
      const match = regex.exec(pattern)

      if (match) {
        const increment = method(match[1])
        const val = '00' + String(date[increment[0]]() + (increment[2] || 0))
        const res = val.slice(-increment[1]) + (match[2] || '')
        pattern = pattern.replace(match[0], res)
        timestamp()
      }
    }

    function method(key) {
      return ({
        YYYY: ['getFullYear', 4],
        YY: ['getFullYear', 2],
        MM: ['getMonth', 2, 1],
        DD: ['getDate', 2],
        HH: ['getHours', 2],
        mm: ['getMinutes', 2],
        ss: ['getSeconds', 2],
        ms: ['getMilliseconds', 3]
      })[key]
    }

    timestamp(pattern)
    return pattern
  }

function log(message) {
    if (!message) return
    const data = `[${stamp("MM/DD HH:mm:ss")}] ${message}`
    if (fs.existsSync(paths.latest)) {
        fs.appendFile(paths.latest, `\n${data}`)
    } else {

    }
    console.log(data)
}

function exit(err, code) {
    log(err.message)
    process.exit(code || 0)
}

class RCON extends EventEmitter {
    constructor(options = {}) {
        super()
        this.host = options.host || 'localhost'
        this.port = options.port || process.env.RCON_PORT
        this.password = options.password || process.env.RCON_PASS
        this.reconnect = options.reconnect || 1000
        this.connected = false
        this.attempts = 0
        this.connect()
    }

    send(command) {
        if (this.ws && this.ws.readyState == 1) {
            this.ws.send(JSON.stringify({
                Identifier: -1,
                Message: command,
                Name: 'WebRcon'
            }))
        }
    }

    connect() {
        this.ws = new WebSocket(`ws://${this.host}:${this.port}/${this.password}`)

        this.ws.on('open', () => {
            this.emit('ready')
            this.connected = true
        })

        this.ws.on('message', (data, flags) => {
            try {
                const json = JSON.parse(data)
                if (json !== undefined) {
                    if (json.Message !== undefined && json.Message.length > 0) {
                        this.emit('message', json.Message)
                    }
                } else {
                    this.emit('error', new Error('Error: Invalid JSON received'))
                }
            } catch (err) {
                if (err) this.emit('error', err)
            }
        })

        this.ws.on('error', (err) => {
            if (!err) return
            if (!this.connected) {
                this.emit('error', new Error(`Failed to connect to rcon, trying again in 1 second (${this.attempts++})`))
                setTimeout(this.connect.bind(this), this.reconnect)
            } else {
                this.emit('error', err)
            }
        })

        this.ws.on('close', () => {
            this.emit('close', this.connected)
        })
    }
}

fs.writeFile(paths.latest, '');

fs.access(paths.exe, fs.constants.X_OK, (err) => {
    if (err) exit(`Error: '${exe}' is not found or is missing permissions to execute!`, 1)

    log(`Starting ${exe} ...`)

    const server = spawn(paths.exe, args, { cwd })
    server.on('exit', (code) => exit(`'${exe}' has exited with code ${code}!`, code))
    server.stdout.on('data', (data) => log(data))
    server.stderr.on('data', (data) => log(data))

    log(`Creating RCON instance ...`)

    const rcon = new RCON()
    rcon.on('ready', () => {
        log('Connected to RCON!')
        process.stdin.resume()
        process.stdin.setEncoding('utf8')
        process.stdin.on('data', (text) => {
            rcon.send(text)
        })
    })

    rcon.on('message', (message) => log(message))
    rcon.on('error', (err) => log(err.message))
    rcon.on('close', (connected) => { if (connected) log('RCON connection closed!') })
})
