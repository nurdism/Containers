const spawn = require('child_process').spawn;
const events = require("events");
const path = require('path');
const cwd = process.cwd();
const fs = require('fs');

const bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
const extend = function(child, parent) { for (let key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };
const hasProp = {}.hasOwnProperty;
const Tail = (function(superClass) {
  extend(Tail, superClass);

  Tail.prototype.readBlock = function() {
    let block, stream;
    if (this.queue.length >= 1) {
      block = this.queue.shift();
      if (block.end > block.start) {
        stream = fs.createReadStream(this.filename, {
          start: block.start,
          end: block.end - 1,
          encoding: this.encoding
        });
        stream.on('error', (function(_this) {
          return function(error) {
            if (_this.logger) {
              _this.logger.error("Tail error: " + error);
            }
            return _this.emit('error', error);
          };
        })(this));
        stream.on('end', (function(_this) {
          return function() {
            if (_this.queue.length >= 1) {
              return _this.internalDispatcher.emit("next");
            }
          };
        })(this));
        return stream.on('data', (function(_this) {
          return function(data) {
            let chunk, i, len, parts, results;
            _this.buffer += data;
            parts = _this.buffer.split(_this.separator);
            _this.buffer = parts.pop();
            results = [];
            for (i = 0, len = parts.length; i < len; i++) {
              chunk = parts[i];
              results.push(_this.emit("line", chunk));
            }
            return results;
          };
        })(this));
      }
    }
  };

  function Tail(filename, options) {
    let pos, ref, ref1, ref2, ref3, ref4, ref5;
    this.filename = filename;
    if (options == null) {
      options = {};
    }
    this.readBlock = bind(this.readBlock, this);
    this.separator = (ref = options.separator) != null ? ref : /[\r]{0,1}\n/, this.fsWatchOptions = (ref1 = options.fsWatchOptions) != null ? ref1 : {}, this.fromBeginning = (ref2 = options.fromBeginning) != null ? ref2 : false, this.follow = (ref3 = options.follow) != null ? ref3 : true, this.logger = options.logger, this.useWatchFile = (ref4 = options.useWatchFile) != null ? ref4 : false, this.encoding = (ref5 = options.encoding) != null ? ref5 : "utf-8";
    if (this.logger) {
      this.logger.info("Tail starting...");
      this.logger.info("filename: " + this.filename);
      this.logger.info("encoding: " + this.encoding);
    }
    this.buffer = '';
    this.internalDispatcher = new events.EventEmitter();
    this.queue = [];
    this.isWatching = false;
    this.internalDispatcher.on('next', (function(_this) {
      return function() {
        return _this.readBlock();
      };
    })(this));
    if (this.fromBeginning) {
      pos = 0;
    }
    this.watch(pos);
  }

  Tail.prototype.watch = function(pos) {
    let stats;
    if (this.isWatching) {
      return;
    }
    this.isWatching = true;
    stats = fs.statSync(this.filename);
    this.pos = pos != null ? pos : stats.size;
    if (this.logger) {
      this.logger.info("filesystem.watch present? " + (fs.watch !== void 0));
      this.logger.info("useWatchFile: " + this.useWatchFile);
    }
    if (!this.useWatchFile && fs.watch) {
      if (this.logger) {
        this.logger.info("watch strategy: watch");
      }
      return this.watcher = fs.watch(this.filename, this.fsWatchOptions, (function(_this) {
        return function(e) {
          return _this.watchEvent(e);
        };
      })(this));
    } else {
      if (this.logger) {
        this.logger.info("watch strategy: watchFile");
      }
      return fs.watchFile(this.filename, this.fsWatchOptions, (function(_this) {
        return function(curr, prev) {
          return _this.watchFileEvent(curr, prev);
        };
      })(this));
    }
  };

  Tail.prototype.watchEvent = function(e) {
    let stats;
    if (e === 'change') {
      stats = fs.statSync(this.filename);
      if (stats.size < this.pos) {
        this.pos = stats.size;
      }
      if (stats.size > this.pos) {
        this.queue.push({
          start: this.pos,
          end: stats.size
        });
        this.pos = stats.size;
        if (this.queue.length === 1) {
          return this.internalDispatcher.emit("next");
        }
      }
    } else if (e === 'rename') {
      this.unwatch();
      if (this.follow) {
        return setTimeout(((function(_this) {
          return function() {
            return _this.watch();
          };
        })(this)), 1000);
      } else {
        if (this.logger) {
          this.logger.error("'rename' event for " + this.filename + ". File not available.");
        }
        return this.emit("error", "'rename' event for " + this.filename + ". File not available.");
      }
    }
  };

  Tail.prototype.watchFileEvent = function(curr, prev) {
    if (curr.size > prev.size) {
      this.queue.push({
        start: prev.size,
        end: curr.size
      });
      if (this.queue.length === 1) {
        return this.internalDispatcher.emit("next");
      }
    }
  };

  Tail.prototype.unwatch = function() {
    if (this.watcher) {
      this.watcher.close();
    } else {
      fs.unwatchFile(this.filename);
    }
    this.isWatching = false;
    return this.queue = [];
  };

  return Tail;

})(events.EventEmitter);

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


const exe =  path.join(cwd, '7DaysToDieServer.x86');
fs.access( exe, fs.constants.X_OK, (err) => {
    if (err) {
        console.log("Error: '7DaysToDieServer.x86' is not found or is missing permissions to execute!");
        process.exit(1);
    }
    const date = new Date().getTime();
    const logfile = path.join(cwd, `7DaysToDieServer_Data/output_log_${date}.txt`);

    fs.access(logfile, fs.constants.F_OK, (err) => {
        if (err) {
            fs.closeSync(fs.openSync(logfile, 'w'));
        }

        const tail = new Tail(logfile);
        tail.on("line", (data) => {
            console.log(`[${stamp("MM:DD HH:mm:ss")}] ${data}`);
        });

        let args = process.argv.slice(2);
        args.unshift(`-logfile`, `7DaysToDieServer_Data/output_log_${date}.txt`);

        const game = spawn( exe, args, { cwd, shell: true, stdio: 'inherit' });
        game.on('exit', (code) => {
            process.exit(code);
        });
    });
});