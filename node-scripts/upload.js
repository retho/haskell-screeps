process.on('unhandledRejection', up => { throw up })
const moment = require('moment');
const argsParser = require("args-parser");
const fs = require('fs');
const fetch = require('node-fetch');
const screepsConfig = require('../screeps.json');

const args = argsParser(process.argv);
const distdir = args.distdir;
if (!distdir) throw new Error('--distdir must be specified');

console.log('uploading...');
fetch(`${screepsConfig.screeps_host}/api/user/code`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json; charset=utf-8',
    'X-Token': screepsConfig.auth_token,
  },
  body: JSON.stringify({
    branch: screepsConfig.branch,
    modules: {
      main: fs.readFileSync(`${distdir}/main.js`, 'utf8'),
      compiled: {binary: fs.readFileSync(`${distdir}/compiled.wasm`).toString('base64')},
    },
  }),
})
  .then(res => Promise.all([res.status, res.json()]))
  .then(([status, body]) => console.log(status, body, body.timestamp ? moment(body.timestamp).format('YYYY-MM-DD HH:mm:ss') : ''));
