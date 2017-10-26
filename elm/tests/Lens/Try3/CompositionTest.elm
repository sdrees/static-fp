module Lens.Try3.CompositionTest exposing (..)

import Test exposing (..)
import TestBuilders exposing (..)
import Lens.Try3.Util exposing (..)
import Dict
import Array

import Lens.Try3.Compose as Lens
import Lens.Try3.Tuple2 as Tuple2
import Lens.Try3.Dict as Dict
import Lens.Try3.Array as Array

compose_classic_with_classic : Test 
compose_classic_with_classic =
  let
    lens = Lens.classicAndClassic Tuple2.first Tuple2.second
    (original, legal) = classicLawSupport
  in
    describe "lens plus lens"
      [ upt   lens (("",        3), "")
                   (("",       -3), "")
      , legal lens (("", original), "")
      ]


compose_classic_with_upsert : Test 
compose_classic_with_upsert =
  let
    lens = Lens.classicAndUpsert Tuple2.first (Dict.lens "key")
    (original, legal) = upsertLawSupport
  in
    describe "lens plus upsert"
      [ describe "update"
          [ upt   lens ( (Dict.singleton "key"  3), "")
                       ( (Dict.singleton "key" -3), "")
          , upt   lens ( (Dict.singleton "---"  3), "")
                       ( (Dict.singleton "---"  3), "")
          , upt   lens (  Dict.empty,               "")
                       (  Dict.empty,               "")
          ]
      , describe "laws"
          [ legal lens ( (Dict.singleton "key" original), "")
          , legal lens ( (Dict.singleton "---" original), "")
          ]
      ]

compose_iffy_with_iffy : Test
compose_iffy_with_iffy =
  let
    lens = Lens.iffyAndIffy (Array.lens 0) (Array.lens 1)
    (original, present, missing) = iffyLawSupport

    a listOfList =
      List.map Array.fromList listOfList
        |> Array.fromList
  in
    describe "iffy + iffy"
      [ describe "update"
          [ upt lens   (a [[0, 3]])   (a [[0, -3]])
          , upt lens   (a [[0   ]])   (a [[0    ]])
          , upt lens   (a [[    ]])   (a [[     ]])
          ]
      , describe "laws"
          [ present lens  (a [[' ', original]])
          , missing lens  (a [[' '          ]])       "short"
          , missing lens  (a [              ])        "missing"
          ]
      ]
  

      
compose_upsert_with_classic : Test
compose_upsert_with_classic =
  let
    lens = Lens.upsertAndClassic (Dict.lens "key") (Tuple2.first)
    (original, present, missing) = iffyLawSupport

    d key tuple = Dict.singleton key tuple
  in
    describe "upsert + classic"
      [ describe "update"
          [ upt lens   (d "key" (3, ""))   (d "key" (-3, ""))
          , upt lens   (d "---" (3, ""))   (d "---" ( 3, ""))
          , upt lens   Dict.empty          Dict.empty
          ]
      , describe "laws"
          [ present lens  (d "key" (original, ""))
          , missing lens  (d "---" (original, ""))    "wrong key"
          , missing lens  Dict.empty                  "missing"
          ]
      ]
  