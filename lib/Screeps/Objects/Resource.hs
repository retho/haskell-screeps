{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}

module Screeps.Objects.Resource
  ( Resource()
  , amount
  , resourceType
  ) where

import Screeps.Utils
import Screeps.Core


foreign import javascript "$1.amount" amount :: Resource -> Int
foreign import javascript "$1.resourceType" resourceType :: Resource -> ResourceType


-- *


