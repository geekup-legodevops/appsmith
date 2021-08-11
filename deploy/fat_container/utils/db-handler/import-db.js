// Init function export mongodb
var shell = require('shelljs')

const MONGO_HOST = process.env.MONGO_HOST
const MONGO_USERNAME= process.env.MONGO_USERNAME
const MONGO_PASSWORD= process.env.MONGO_PASSWORD
const MONGO_DATABASE= process.env.MONGO_DATABASE
const RESTORE_PATH = '/opt/appsmith/data/restore'

function import_database() {
	console.log('import_database  ....')
	const cmd = `mongorestore --uri='mongodb://${MONGO_USERNAME}:${MONGO_PASSWORD}@${MONGO_HOST}/${MONGO_DATABASE}' --gzip --archive=${RESTORE_PATH}/data.archive`
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
		console.log('check_supervisord_status_cmd')
		check_supervisord_status_cmd = '/usr/bin/supervisorctl'
		const {code } = shell.exec(check_supervisord_status_cmd, {async: true, silent: true})
		if(code > 0  ) {
		shell.echo('application is not running, starting supervisord')
		shell.exec('/usr/bin/supervisord', {async: true})
		}
		console.log('check_supervisord_status_cmd done')

		shell.echo('stop_application')
		stop_application()
		shell.echo('import_database')
		import_database()
		shell.echo('start_application')
		start_application()
		shell.echo('Import database done')
		process.exit(0);
	} catch (err) {
		console.log(err);
		shell.echo(err)
		process.exit(1);
	}

}
// Run application
main()