// Init function export mongodb
var shell = require('shelljs')

// Load env configuration
const MONGO_HOST = process.env.MONGO_HOST
const MONGO_USERNAME= process.env.MONGO_USERNAME
const MONGO_PASSWORD= process.env.MONGO_PASSWORD
const MONGO_DATABASE= process.env.MONGO_DATABASE
const BACKUP_PATH = '/opt/appsmith/data/backup'

async function export_database() {
  shell.mkdir('-p', [`${BACKUP_PATH}`]);
  const cmd = `mongodump --host=${MONGO_HOST} --username=${MONGO_USERNAME} --password=${MONGO_PASSWORD} --db=${MONGO_DATABASE} --archive=${BACKUP_PATH}/data.archive --gzip`
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


// Main application workflow
check_supervisord_status_cmd = '/usr/bin/supervisorctl >/dev/null'
shell.exec(check_supervisord_status_cmd, function (code) {
  if (code != 0) {
    shell.exec('/usr/bin/supervisorcd')
  }
})
stop_application
  .then(export_database)
  .then(start_application)