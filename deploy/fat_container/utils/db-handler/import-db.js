// Init function export mongodb
var shell = require('shelljs')

const APPSMITH_MONGO_HOST = process.env.APPSMITH_MONGO_HOST
const APPSMITH_MONGO_USERNAME= process.env.APPSMITH_MONGO_USERNAME
const APPSMITH_MONGO_PASSWORD= process.env.APPSMITH_MONGO_PASSWORD
const APPSMITH_MONGO_DATABASE= process.env.APPSMITH_MONGO_DATABASE
const RESTORE_PATH = '/opt/appsmith/data/restore'

function import_database() {
	console.log('import_database  ....')
	const cmd = `mongorestore --uri='mongodb://${APPSMITH_MONGO_USERNAME}:${APPSMITH_MONGO_PASSWORD}@${APPSMITH_MONGO_HOST}/${APPSMITH_MONGO_DATABASE}' --gzip --archive=${RESTORE_PATH}/data.archive`
	console.log('executing: ' + cmd)
	shell.exec(cmd)
	console.log('import_database done')
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
		check_supervisord_status_cmd = '/usr/bin/supervisorctl'
    shell.exec(check_supervisord_status_cmd, function(code) {
      if(code > 0  ) {
        shell.echo('application is not running, starting supervisord')
        shell.exec('/usr/bin/supervisord')
      }
    })


		shell.echo('stop backend & rts application')
		stop_application()
		shell.echo('importing database ....')
		import_database()
		shell.echo('import database done!')
		shell.echo('start backend & rts application')
		start_application()
		process.exit(0);
	} catch (err) {
		console.log(err);
		shell.echo(err)
		process.exit(1);
	}

}
// Run application
main()