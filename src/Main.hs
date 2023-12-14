module Main (main, reanimateLive) where

import Control.Lens
import qualified Data.Text as T
import Main.Utf8 (withUtf8)
import Reanimate
import Reanimate.Builtin.Documentation
import Reanimate.Scene
import Reanimate.Voice
import Text.Printf
import Colors

main :: IO ()
main =
  withUtf8 . reanimate $ sinExample

sinExampleTranscript = fakeTranscript "As an example we will use the sin function\n"

sinExample :: Animation
sinExample = env $
  scene $ do
    -- eq <- oNew equation
    -- oShowWith eq oDraw
    -- wait 1
    -- oHideWith eq oFadeOut

    -- wait 1

    newSpriteSVG_ grid
    newSpriteSVG_ $ redDot (0.0, 0.0)
    newSpriteSVG_ $ generateEvenlySpacedDotsOfSin 5

    wait 1

generateEvenlySpacedDotsOfSin dotCount = mkGroup [redDot p | p <- helper (-8)]
  where
    helper xVal = if xVal < 16 then (xVal, ((*3.5) . sin) xVal):helper (xVal + stepSize) else []
    stepSize = 16 / dotCount

outlinedText :: Text -> SVG
outlinedText txt =
  mkGroup
    [ center $
        withStrokeColorPixel backgroundColor $
          withStrokeWidth (defaultStrokeWidth * 4) $
            withFillOpacity 0 $
              latex txt,
      withStrokeWidth (defaultStrokeWidth * 0.5) $ withStrokeColorPixel textColor $ center $ latex txt
    ]

redDot :: (Double, Double) -> SVG
redDot (x, y) =
  translate x y $ withFillColorPixel purple $ mkCircle 0.1

redDotLabeled :: (Double, Double) -> SVG
redDotLabeled (x, y) =
  translate x y $
    mkGroup
      [ translate 0 (-0.5) $ scale 0.5 $ outlinedText $ T.pack $ printf "%.1f, %.1f" x y,
        withFillColorPixel purple $ mkCircle 0.1
      ]

grid :: SVG
grid =
  mkGroup
    [ withStrokeColorPixel textColor $ mkLine (- screenWidth, 0) (screenWidth, 0),
      withStrokeColorPixel textColor $ mkLine (0, - screenHeight) (0, screenHeight),
      withStrokeColorPixel textColor $
        withStrokeWidth (defaultStrokeWidth * 0.5) $
          mkGroup
            [ mkGroup
                [ translate
                    0
                    (i / screenHeight * screenHeight - screenHeight / 2 - screenHeight / 18)
                    $ mkLine (- screenWidth, 0) (screenWidth, 0)
                  | i <- [0 .. screenHeight]
                ],
              mkGroup
                [ translate (i / screenWidth * screenWidth - screenWidth / 2) 0 $
                    mkLine (0, - screenHeight) (0, screenHeight)
                  | i <- [0 .. screenWidth]
                ]
            ]
    ]

equation :: SVG
equation =
  scale 2 $
    center $
      latexAlign "\\sin(x)"

env :: Animation -> Animation
env = addStatic bg

bg :: SVG
bg = mkBackground "white"
