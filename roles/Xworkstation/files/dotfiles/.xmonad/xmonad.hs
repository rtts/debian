import XMonad
import XMonad.Layout.Gaps
import XMonad.Layout.Spacing
import XMonad.Layout.NoBorders

myManageHook = composeAll
  [ className =? "Gimp" --> doFloat
  , className =? "Clock" --> doIgnore
  , className =? "trayer" --> doIgnore
  , className =? "mednafen" --> doIgnore
  ]

myLayout = full ||| tiled
  where full  = noBorders $ (spacing 0) $ gaps [(D,5)] $ Full
        tiled = smartBorders $ (spacing 2) $ gaps [(D,5),(U,35)] $ Tall 1 (1/80) 0.5

main = xmonad $ def
  { borderWidth = 2
  , normalBorderColor = "#000099"
  , focusedBorderColor = "#ff0000"
  , modMask = mod4Mask
  , manageHook = myManageHook
  , layoutHook = myLayout
  , focusFollowsMouse = False
  , clickJustFocuses = True
  }
