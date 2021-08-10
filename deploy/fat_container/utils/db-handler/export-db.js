// Init function export mongodb
var shell = require('shelljs')
var mongojs = require('mongojs')
var db = mongojs('username:password@localhost:27017/sampleDB')
db.getCollectionNames(function (err, names) {
  if (err) {
    console.log(err)
    process.exit(1)
  }
  names.forEach((name) => {
    var cmd = 'mongoimport --db sampleDB --collection ' + name + ' --type json --file D:\\' + name + '.json'
    console.log('executing: ' + cmd)
    shell.exec(cmd, function (code, stdout, stderr) {
      if (code != 0) {
        console.error('Error: ' + code)
        console.log('Program output:', stdout)
        console.log('Program stderr:', stderr)
      }
    })
  })
  process.exit(0)
})