module Main (main, reanimateLive) where

import Control.Lens
import Main.Utf8 (withUtf8)
import Reanimate
import Reanimate.Builtin.Documentation
import Reanimate.Scene

main :: IO ()
main =
  withUtf8 . reanimate $ sinExample

sinExample :: Animation
sinExample = env $
  scene $ do
    obj <- oNew equation
    oShow obj

    oTweenS obj 1 moveTopLeftAndScaleDownSlightly

    wait 1

moveTopLeftAndScaleDownSlightly t = do
  oCenterX (Double -> f Double) (ObjectData a)
  oScale %= \origin ->
    fromToS origin 0.5 t

equation :: SVG
equation =
  scale 2 $
    center $
      latexAlign "\\sin(x)"

env :: Animation -> Animation
env = addStatic bg

bg :: SVG
bg = mkBackground "white"