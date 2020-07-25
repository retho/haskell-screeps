{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

import Prelude hiding (break)
import Screeps.Prelude

import Text.Printf (printf)
import Control.Monad (when, void)
import Data.Foldable (for_)

import Screeps.Constants.FindConstant
import Screeps.Objects.RoomPosition (isNearTo)

import qualified Screeps.Game as Game
import qualified Screeps.Memory as Mem
import qualified Screeps.Game.CPU as Game.CPU
import qualified Screeps.Objects.Room as Room
import qualified Screeps.Objects.Creep as Creep
import qualified Screeps.Objects.Structure.StructureSpawn as Spawn
import qualified Screeps.Constants.BodyPart as BodyPart
import qualified Screeps.Constants.ResourceType as ResourceType
import qualified Screeps.Constants.ReturnCode as ReturnCode

import Logging as Logging

main :: IO ()
main = do
  Game.CPU.getUsed >>= \cpu -> debug $ "loop starting! cpu: " <> showjs cpu
  setupLogging Logging.Info

  game_spawns <- Game.spawns
  for_ (values game_spawns) $ \spawn -> do
    debug $ "running spawn " <> Spawn.name spawn
    let body = [BodyPart.move, BodyPart.move, BodyPart.carry, BodyPart.work]
    when (storeUsedCapacity spawn (pure ResourceType.energy) >= sum (map BodyPart.cost body)) $ do
      -- * create a unique name, spawn.
      name_base <- Game.time
      let
        loop :: (a -> Bool) -> [IO a] -> IO a
        loop _ [] = undefined
        loop break (x:xs) = x >>= \r -> if break r then pure r else loop break xs
      res <- loop (/= ReturnCode.err_name_exists) $ flip map [0..] $ \(additional :: Int) -> do
        let name = showjs name_base <> "-" <> showjs additional
        Spawn.spawnCreep spawn body name
      when (res /= ReturnCode.ok) $ do
        warn $ "couldn't spawn: " <> showjs res

  debug "running creeps"
  game_creeps <- Game.creeps
  for_ (values game_creeps) $ \creep -> do
    let name = Creep.name creep
    debug $ "running creep " <> name
    when (not $ Creep.spawning creep) $ do
      Mem.get "harvesting" (memory creep) >>= pure . maybe False id >>= \harvesting ->
        if harvesting
          then when (storeFreeCapacity creep (Just ResourceType.energy) == 0) $ Mem.set "harvesting" False $ memory creep
          else when (storeUsedCapacity creep (Just ResourceType.energy) == 0) $ Mem.set "harvesting" True $ memory creep
      Mem.get "harvesting" (memory creep) >>= pure . maybe False id >>= \harvesting ->
        if harvesting
          then do
            source <- Room.find find_sources (Creep.room creep) >>= pure . (!! 0)
            if creep `isNearTo` source
              then Creep.harvest creep source >>= \r -> when (r /= ReturnCode.ok) . warn $ "couldn't harvest: " <> showjs r
              else void $ Creep.moveTo creep source
          else do
            let mc = Room.controller (Creep.room creep)
            case mc of
              Just c -> do
                r <- Creep.upgradeController creep c
                if r == ReturnCode.err_not_in_range
                  then void $ Creep.moveTo creep c
                  else when (r /= ReturnCode.ok) . warn $ "couldn't upgrade: " <> showjs r
              Nothing -> warn "creep room has no controller!"

  time <- Game.time
  when (time `mod` 32 == 3) $ do
    info "running memory cleanup"
    cleanup_memory

  Game.CPU.getUsed >>= \cpu -> info . toJSString $ printf "done! cpu: %.2f" cpu


cleanup_memory :: IO ()
cleanup_memory = do
  alive_creeps <- Game.creeps >>= pure . keys
  let creeps_mem = Mem.path Mem.root ["creeps"]
  creeps_memory_keys <- Mem.keys creeps_mem >>= pure . maybe [] id

  for_ creeps_memory_keys $ \mem_name -> do
    when (mem_name `notElem` alive_creeps) $ do
      debug $ "cleaning up creep memory of dead creep " <> mem_name
      Mem.del creeps_mem mem_name
