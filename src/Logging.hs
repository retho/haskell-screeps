{-# LANGUAGE OverloadedStrings #-}

module Logging
  ( setupLogging
  , debug
  , info
  , warn
  , Logging(..)
  ) where

import Screeps.Prelude
import Control.Monad (when)

data Logging = Debug | Info | Warn deriving (Eq, Ord, Enum)

instance JSShow Logging where
  jsshow Debug = "[DEBUG]"
  jsshow Info = "[INFO]"
  jsshow Warn = "[WARN]"

foreign import javascript "global.LOG_LEVEL = $1" set_log_level :: Int -> IO ()
foreign import javascript "global.LOG_LEVEL" get_log_level :: IO JSVal

setupLogging :: Logging -> IO ()
setupLogging = set_log_level . fromEnum

getLogging :: IO Logging
getLogging = get_log_level >>= pure . maybe Info toEnum . fromNullableJSVal

logger :: Logging -> JSString -> IO ()
logger logger_logging msg = do
  current_logging <- getLogging
  when (logger_logging >= current_logging) $ consoleLog $ jsshow logger_logging <> " " <> msg

debug = logger Debug
info = logger Info
warn = logger Warn
