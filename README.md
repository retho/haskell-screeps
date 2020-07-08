


# Scripts

`npm start` show compilation error on changes in `src/*`

`npm run deploy` compiles and uploads the code to the server (based on settings in `screeps.json`)

`npm run test:<env-name> -- --suite=<suite-path>` runs test suite within environment `<env-name>`, where `<suite-path>` is path to folder with test (e.g. `--suite=tests/basic`)
- `npm run test:node-screeps -- --suite=...` must work as well as `npm run test:node-native -- --suite=...` (this check may be useful when updating docker image `terrorjack/asterius:<version>`)
