// Init function export mongodb
var shell = require('shelljs')

const MONGO_HOST = process.env.MONGO_HOST
const MONGO_USERNAME= process.env.MONGO_USERNAME
const MONGO_PASSWORD= process.env.MONGO_PASSWORD
const MONGO_DATABASE= process.env.MONGO_DATABASE
const BACKUP_PATH = '/opt/appsmith/data/backup'

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