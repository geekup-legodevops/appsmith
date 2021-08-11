// Init function export mongodb
var shell = require('shelljs')

const MONGO_HOST = process.env.MONGO_HOST
const MONGO_USERNAME= process.env.MONGO_USERNAME
const MONGO_PASSWORD= process.env.MONGO_PASSWORD
const MONGO_DATABASE= process.env.MONGO_DATABASE
const BACKUP_PATH = '/opt/appsmith/data/backup'

const cmd = `mongorestore --uri='mongodb://${MONGO_USERNAME}:${MONGO_PASSWORD}@${MONGO_HOST}/${MONGO_DATABASE}' --gzip --archive=${BACKUP_PATH}/data.archive`
console.log('executing: ' + cmd)
shell.exec(cmd, function (code, stdout, stderr) {
	if (code != 0) {
	console.error('Error: ' + code)
	console.log('Program output:', stdout)
	console.log('Program stderr:', stderr)
	}
})