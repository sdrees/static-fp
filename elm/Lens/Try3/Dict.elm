module Lens.Try3.Dict exposing
  ( lens
  , humbleLens
  )

import Lens.Try3.Lens as Lens
import Lens.Try3.Compose as Compose
import Dict exposing (Dict)

{- This lens can add keys or delete them. -}

lens : comparable -> Lens.Upsert (Dict comparable val) val
lens key =
  Lens.upsert (Dict.get key) (Dict.insert key) (Dict.remove key)

-- Todo: should probably create this directly for efficiency    
humbleLens : comparable -> Lens.Humble (Dict comparable val) val
humbleLens key =
  lens key |> Compose.upsertToHumble

