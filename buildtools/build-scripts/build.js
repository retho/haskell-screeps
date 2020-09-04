process.on('unhandledRejection', up => { throw up })
const { execSync } = require('child_process')
const run = (cmd) => execSync(cmd, {stdio: [process.stdin, process.stdout, process.stderr]})

const gcThreshold = 1; // in MBs
const optimizeLevel = 4; // Valid values are 0 to 4
const shrinkLevel = 2; // Valid values are 0 to 2

const rollupconfigdir = 'buildtools/rollup'
const builddir = '.cabal-screeps-work/ahc-cabal-build'
const rollupinputdir = '.cabal-screeps-work/rollup-input'
const distdir = '.dist'

run(`rm -rf ${rollupinputdir}`)
run(`rm -rf ${distdir}`)

run(`ahc-cabal v1-install -j --bindir=${rollupinputdir} --builddir=${builddir}`)
run(`ahc-dist --input-exe=${rollupinputdir}/main --browser --gc-threshold=${gcThreshold} --optimize-level=${optimizeLevel} --shrink-level=${shrinkLevel}`)

run(`cp -rf ${rollupconfigdir}/assets/screeps_environment/. ${rollupinputdir}`)
run(`cp -rf ${rollupconfigdir}/assets/entry/. ${rollupinputdir}`)
run(`npx rollup -c=${rollupconfigdir}/rollup.config.js`)
run(`cp ${rollupinputdir}/main.wasm ${distdir}/compiled.wasm`)
