-- import XMonad.Layout.ResizableThreeColumns

import qualified Data.Map as M
import Data.Monoid
import System.Exit
import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.DynamicWorkspaces (addWorkspacePrompt, removeWorkspace)
import XMonad.Actions.Minimize
import XMonad.Actions.RotSlaves
import XMonad.Actions.Submap
import XMonad.Actions.WindowGo
import XMonad.Actions.WorkspaceNames
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Layout
import XMonad.Layout.Accordion
import qualified XMonad.Layout.BoringWindows as BW
import XMonad.Layout.GridVariants
import XMonad.Layout.Magnifier as Mag
import XMonad.Layout.Minimize
import XMonad.Layout.MultiColumns
import XMonad.Layout.Renamed
import XMonad.Layout.Spiral
import XMonad.Layout.ThreeColumns (ThreeCol (ThreeCol))
import XMonad.Prompt
import XMonad.Prompt.RunOrRaise
import XMonad.Prompt.Workspace
import qualified XMonad.StackSet as W
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run
import XMonad.Util.SpawnOnce

myTerminal :: String
myTerminal = "alacritty"

myTerminalClass :: String
myTerminalClass = "Alacritty"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myClickJustFocuses :: Bool
myClickJustFocuses = False

myBorderWidth = 5

myModMask = mod4Mask

-------------------------------------------------
-- Key Bindings
-------------------------------------------------

myKeys conf@(XConfig {XMonad.modMask = modm}) =
  M.fromList $
    [ ((modm, xK_space), namedScratchpadAction myScratchPads "terminal")
    ]

-------------------------------------------------
-- Named Scratchpad
-------------------------------------------------
myScratchPads :: [NamedScratchpad]
myScratchPads =
  [ NS "terminal" myTerminal (className =? myTerminalClass) manageTerm
  ]
  where
    manageTerm = doRectFloat $ W.RationalRect x y w h
      where
        x = 0
        y = 0.02
        w = 1
        h = 0.98

main :: IO ()
main =
  xmonad
    def
      { terminal = myTerminal,
        focusFollowsMouse = myFocusFollowsMouse,
        clickJustFocuses = myClickJustFocuses,
        borderWidth = myBorderWidth,
        modMask = myModMask,
        keys = myKeys
      }
