module Main (main, reanimateLive) where

import Main.Utf8 (withUtf8)
import Reanimate
import Reanimate.Builtin.Documentation

main :: IO ()
main =
  withUtf8 . reanimate $
    docEnv $ drawBox `parA` drawCircle
