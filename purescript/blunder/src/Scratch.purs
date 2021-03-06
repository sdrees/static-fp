module Scratch where

import Prelude

import Data.List as List
import Data.List (List)   

import Data.Array
import Data.Tuple


--- For part 1
intList :: List Int
intList = List.singleton 555

tuple = Tuple 1.0 1

--- For part 2
intArray = singleton 3

-- Parts 3 and 4
data MyType wrapped = First wrapped | Second

instance showMyType :: Show wrapped => Show (MyType wrapped) where
  show (First x) = "(First " <> show x <> ")"
  show Second  = "Second"

-- Parts 5 and 6
-- cases :: Partial => Int -> Int -> Int
cases 0 0 = 10
cases 0 1 = -1
cases _ 3 = -3
cases 8 _ = -8
-- cases x y = x + y
