// Init function export mongodb
var shell = require('shelljs')

// Load env configuration
const MONGO_HOST = process.env.MONGO_HOST
const MONGO_USERNAME= process.env.MONGO_USERNAME
const MONGO_PASSWORD= process.env.MONGO_PASSWORD
const MONGO_DATABASE= process.env.MONGO_DATABASE

async function export_database() {
  const cmd = `mongodump --host=${MONGO_HOST} --username=${MONGO_USERNAME} --password=${MONGO_PASSWORD} --db=${MONGO_DATABASE} --archive=/opt/appsmith/data/mongodb --gzip`
  console.log('executing: ' + cmd)
  shell.exec(cmd, function (code, stdout, stderr) {
    if (code != 0) {
    console.error('Error: ' + code)
    console.log('Program output:', stdout)
    console.log('Program stderr:', stderr)
    }
  })
}

async function stop_application() {
  await shell.exec('/usr/bin/supervisorctl stop backend rts')
}

async function start_application() {
  await shell.exec('/usr/bin/supervisorctl start backend rts')
}

//  Main application workflow
stop_application.then(export_database).then(start_application)