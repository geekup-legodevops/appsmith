
`cd app/client`
**Note** Dùng node 14 nha anh
`npm install`
`npm run build`

`cd ../server`
`mvn clean compile`
`cp envs/dev.env.example .env`
**Note** Sửa 2 URI của mongo với redis trong .env về localhost nha anh

`./build.sh -Dmaven.test.skip=true`
`cd ../../`
`docker build -t appsmith_test_adding_apps .`
`docker-compose up`