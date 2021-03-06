module Lens.Final.Result exposing
  ( okLens
  , errLens
  )

import Lens.Final.Lens as Lens

okLens : Lens.OneCase (Result err ok) ok
okLens =
  Lens.oneCase Result.toMaybe Ok

errLens : Lens.OneCase (Result err ok) err
errLens =
  let
    get big =
      case big of
        Err e -> Just e
        _  -> Nothing
  in
    Lens.oneCase get Err

