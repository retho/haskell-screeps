import './screeps.env.debug.mjs';
import './screeps.env.queue.mjs';
import './screeps.env.promise.mjs';
import './screeps.env.text-encoding.mjs';

global.IS_SIMULATION = Game && Game.rooms && 'sim' in Game.rooms;
