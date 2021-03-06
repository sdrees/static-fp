module Choose.MaybeLensTest exposing (..)

import Test exposing (..)
import TestBuilders exposing (..)
import Choose.MaybeLens as Chooser exposing (MaybeLens)
import Choose.Combine.MaybeLens as Chooser
import Choose.Operators exposing (..)
import Choose.Common.Dict as Dict
import Choose.Common.Array as Array
import Choose.Common.List as List
import Choose.Combine.Lens as Lens
import Choose.Common.Tuple2 as Tuple2
import Choose.Definitions as D
import Dict
import Array

-------- Key to the conceptual map:

-- Since `Dict` is the natural type to use with `MaybeLens`, here
-- are some constructors that make tests more readable. 
-- Key thing is that the topmost key is the function name.
one = D.dict1_1 "one"      -- make {"one": {key: val}} with given key/val
other = D.dict1_1 "other"  -- ditto, but {"other": {key: val}}
oneIsEmpty = D.dict1 "one" Dict.empty  -- {"one" : Dict.empty}

oneValue = Chooser.make (Dict.get "one") (Dict.insert "one")


--- Tests
           
operations : Test
operations =
  let
    (get, set, update) = accessors oneValue
  in
    describe "operations" 
      [ equal_ (get           <| D.dict1 "one" 58)    (Just 58)
      , equal_ (get           <| Dict.empty)           Nothing

      , equal_ (set 0         <| D.dict1 "one" 3)     (D.dict1 "one" 0)
      , equal_ (set 9         <| Dict.empty)          (D.dict1 "one" 9)

      , equal_ (update negate <| D.dict1 "one" 58)    (D.dict1 "one" -58)
      , equal_ (update negate <| Dict.empty)           Dict.empty
      ]

-- Conventions:
--   Value to be set starts out as "focus"
--   It's set to "new"

lawTests : MaybeLens whole String -> whole -> String
         -> Test
lawTests chooser whole comment =
  let
    (get, set, _) = accessors chooser
  in
    describe comment
      [ -- 1. if you `set` the part that `get` provides, whole is unchanged
        equal (get whole)           (Just "focus")   "here's what the get returns"
      , equal (set "focus" whole)   whole            "setting it to original"

      -- 2. What you `set` is what you `get`
      , equal_ (set "new" whole |> get)  (Just "new")
      ]


laws =
  describe                                   "laws for MaybeLens"
    [ lawTests (Dict.valueAt "key")
               (D.dict1 "key" "focus")                       "Dict"
    , lawTests (Array.valueAt 1)
               (Array.fromList ["", "focus", ""])            "Array"
    , lawTests List.first ["focus"]                          "List"
    ]
    
conversionsFollowLaws =
  describe                                   "laws For conversions"
    [ lawTests (Chooser.fromCase D.name) (D.Name "focus")      "from Case (prism)"
    , lawTests (Chooser.fromLens Tuple2.second)  (1, "focus")  "from Lens (lens)"
    ]

combinationsFollowLaws =
  describe                                   "laws for combinations"
    [ lawTests (Dict.valueAt "one" ~..~ Dict.valueAt "two")
               (one "two" "focus")               "with own type"
    , lawTests (Dict.valueAt "one" ~... Tuple2.second)
               (D.dict1 "one" (1, "focus"))                  "with part"
    , lawTests (Dict.valueAt "one" ~..> D.name)
               (D.dict1 "one" (D.Name "focus"))           "with case"
    ]

compositionHasQuirksInSet =
  let
    composed = Dict.valueAt "one" |> Chooser.next (Dict.valueAt "two")
    (get, set, update) = accessors composed
  in
    describe "composition"
      [ describe "get" 
          [ equal_ (get <| one "two" 1.2)    (Just 1.2)
          , equal  (get <| one "ZZZ" 1.2)    Nothing  "no last key"
          , equal  (get <| oneIsEmpty)       Nothing  "alternate to above"
          , equal  (get <| Dict.empty)       Nothing  "no first key"
          ]
      , describe "set"
          [ equal_ (set 8.8 <| one "two" 0000)    (one "two" 8.8)
          , equal_ (set 2.2 <| oneIsEmpty)        (one "two" 2.2)

          -- You might expect the following two cases to do this:
          -- , equal_ (set 9.3 <| other "two" 0000)   (Dict.union (other "two" 0000)
          --                                                  (one "two" 9.3))
          --, equal_ (set 9.3 Dict.empty)            (one "two" 9.3)
          --
          -- But they actually make no change because two levels of key
          -- would have to be added.
          , unchanged (set 9.3) (other "two" 0000)  "top-level key is 'two'"
          , unchanged (set 9.3) Dict.empty          "no top-level key"
          ]
      , describe "update"
          [ equal_    ((update negate)  (one "two" 1))    (one "two" -1)
          , unchanged  (update negate)  oneIsEmpty        "Nothing to get for 'two', so nothing to update"
          , unchanged  (update negate)  Dict.empty        "ditto, but not even top level"
          ]
      ]


-- Util

accessors partChooser =
  ( Chooser.get partChooser
  , Chooser.set partChooser
  , Chooser.update partChooser
  )

