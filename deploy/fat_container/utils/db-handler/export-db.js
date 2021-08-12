// Init function export mongodb
var shell = require('shelljs')

// Load env configuration
const APPSMITH_MONGO_HOST = process.env.APPSMITH_MONGO_HOST
const APPSMITH_MONGO_USERNAME= process.env.APPSMITH_MONGO_USERNAME
const APPSMITH_MONGO_PASSWORD= process.env.APPSMITH_MONGO_PASSWORD
const APPSMITH_MONGO_DATABASE= process.env.APPSMITH_MONGO_DATABASE

const BACKUP_PATH = '/opt/appsmith/data/backup'
const RESTORE_PATH = '/opt/appsmith/data/restore'

function export_database() {
  console.log('export_database  ....')
  shell.mkdir('-p', [`${BACKUP_PATH}`]);
  const cmd = `mongodump --host=${APPSMITH_MONGO_HOST} --username=${APPSMITH_MONGO_USERNAME} --password=${APPSMITH_MONGO_PASSWORD} --db=${APPSMITH_MONGO_DATABASE} --archive=${BACKUP_PATH}/data.archive --gzip`
  console.log('executing: ' + cmd)
  shell.exec(cmd)
  console.log('export_database done')
}

function stop_application() {
  console.log('stop_application  ....')
  shell.exec('/usr/bin/supervisorctl stop backend rts')
  console.log('stop_application done')
}

function start_application() {
  console.log('start_application  ....')
  shell.exec('/usr/bin/supervisorctl start backend rts')
  console.log('start_application done')
}

// Main application workflow
function main() {
  try {
    check_supervisord_status_cmd = '/usr/bin/supervisorctl >/dev/null 2>&1 '
    shell.exec(check_supervisord_status_cmd, function(code) {
      if(code > 0  ) {
        shell.echo('application is not running, starting supervisord')
        shell.exec('/usr/bin/supervisord')
      }
    })

    shell.echo('stop backend & rts application')
    stop_application()
    shell.echo('exporting database ....')
    export_database()
    shell.echo('import database done!')
    shell.echo('start backend & rts application')
    start_application()
    shell.echo('Export database done')
    process.exit(0);
  } catch (err) {
    console.log(err);
    shell.echo(err)
    process.exit(1);
  }
 
}

// Run application
main()
