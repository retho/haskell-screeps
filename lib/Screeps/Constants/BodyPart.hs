{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Screeps.Constants.BodyPart
  ( cost
  , BodyPart(..)
  , move
  , work
  , carry
  , attack
  , ranged_attack
  , tough
  , heal
  , claim
  ) where

import Screeps.Utils

newtype BodyPart = BodyPart JSString deriving (JSShow, JSIndex, JSRef, Eq)

foreign import javascript "BODYPART_COST[$1]" cost :: BodyPart -> Int

foreign import javascript "MOVE" move :: BodyPart
foreign import javascript "WORK" work :: BodyPart
foreign import javascript "CARRY" carry :: BodyPart
foreign import javascript "ATTACK" attack :: BodyPart
foreign import javascript "RANGED_ATTACK" ranged_attack :: BodyPart
foreign import javascript "TOUGH" tough :: BodyPart
foreign import javascript "HEAL" heal :: BodyPart
foreign import javascript "CLAIM" claim :: BodyPart
