// Init function export mongodb
var shell = require('shelljs')

const MONGO_HOST = process.env.MONGO_HOST
const MONGO_USERNAME= process.env.MONGO_USERNAME
const MONGO_PASSWORD= process.env.MONGO_PASSWORD
const MONGO_DATABASE= process.env.MONGO_DATABASE

const cmd = `mongodump --host=${MONGO_HOST} --username=${MONGO_USERNAME} --password=${MONGO_PASSWORD} --db=${MONGO_DATABASE} --archive=/opt/appsmith/data/mongodb --gzip`
console.log('executing: ' + cmd)
shell.exec(cmd, function (code, stdout, stderr) {
	if (code != 0) {
	console.error('Error: ' + code)
	console.log('Program output:', stdout)
	console.log('Program stderr:', stderr)
	}
})
// var mongojs = require('mongojs')
// var db = mongojs('appsmith:appsmith@localhost:27017/appsmith')
// db.getCollectionNames(function (err, names) {
//   if (err) {
//     console.log(err)
//     process.exit(1)
//   }
//   names.forEach((name) => {
//     // var cmd = 'mongoimport --db appsmith --collection ' + name + ' --type json --file D:\\' + name + '.json'
// 	var cmd = 'mongodump --host=localhost --port=27017 --username=appsmith --password=appsmith --db=appsmith appsmith --archive=. --gzip'
//     console.log('executing: ' + cmd)
//     shell.exec(cmd, function (code, stdout, stderr) {
//       if (code != 0) {
//         console.error('Error: ' + code)
//         console.log('Program output:', stdout)
//         console.log('Program stderr:', stderr)
//       }
//     })
//   })
//   process.exit(0)
// })