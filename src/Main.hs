{-# OPTIONS_GHC -Wall #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

import Screeps.Prelude
import Control.Monad (when)
import Text.Printf (printf)

import qualified Screeps.Game as Game
import qualified Screeps.Game.CPU as Game.CPU

import Logging as Logging

fibs :: [Int]
fibs = 1 : 1 : zipWith (+) fibs (tail fibs)

printSystemStats :: IO ()
printSystemStats = do
  cpu_used <- Game.CPU.getUsed
  maybe_heap_stats <- Game.CPU.getHeapStatistics
  let
    memory_used :: Double =
      maybe
        0
        (\x -> 100 * fromIntegral (Game.CPU.used_heap_size x) / fromIntegral (Game.CPU.heap_size_limit x))
        maybe_heap_stats
  info $ toJSString $ printf "system stats: %.2f cpu used, %.2f%% total memory used" cpu_used memory_used

main :: IO ()
main = do
  setupLogging Logging.Info
  t <- Game.time
  let fib_index = t `mod` 64
  info $ "fib " <> jsshow (fib_index + 1) <> " = " <> jsshow (fibs !! fib_index)
  when (t `mod` 8 == 0) printSystemStats
