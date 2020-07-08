import './polyfill.mjs';
import * as rts from "./rts.mjs";
import m from "./Main.wasm.mjs";
import req from "./Main.req.mjs";

const i = rts.newAsteriusInstance(Object.assign(req, {module: m}));

module.exports.loopPromise = Promise.resolve(() =>
  i.exports.main()
    .catch(err => {
      if (!(err.startsWith('ExitSuccess') || err.startsWith('ExitFailure '))) i.fs.writeSync(2, `Main: ${err}`);
    })
);