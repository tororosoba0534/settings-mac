import qualified Data.Map as M
import System.Exit
import XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.WorkspaceNames
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Layout.MultiColumns (multiCol)
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

myBorderWidth :: Dimension
myBorderWidth = 5

myModMask :: KeyMask
myModMask = mod4Mask

-------------------------------------------------
-- Key Bindings
-------------------------------------------------

myKeys :: XConfig Layout -> M.Map (ButtonMask, KeySym) (X ())
myKeys conf@(XConfig {XMonad.modMask = modm}) =
  M.fromList
    [ ((modm, xK_space), namedScratchpadAction myScratchPads "terminal"),
      ((modm, xK_o), spawn "dmenu_run"),
      ((modm, xK_c), kill),
      ((modm .|. shiftMask, xK_q), io exitSuccess),
      ((modm, xK_q), unsafeSpawn "xmonad --recompile && xmonad --restart"),
      -- -- Move focus to the other window
      -- next
      ((modm, xK_j), windows W.focusUp),
      -- previous
      ((modm, xK_k), windows W.focusDown),
      -- -- Move current workspace
      -- right
      ((modm, xK_l), moveTo Next $ Not emptyWS :&: ignoringWSs [scratchpadWorkspaceTag]),
      -- left
      ((modm, xK_h), moveTo Prev $ Not emptyWS :&: ignoringWSs [scratchpadWorkspaceTag]),
      -- -- Layout
      -- next
      ((modm, xK_w), sendMessage NextLayout)
    ]

-------------------------------------------------
-- Workspaces
-------------------------------------------------
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

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

myStartupHook :: X ()
myStartupHook = do
  spawnOnce "xremap ~/settings-mac/.config/xremap/config.yml"

mySB :: StatusBarConfig
mySB =
  statusBarProp
    "xmobar -x 0 ~/.config/xmobar/xmobar.hs"
    ( workspaceNamesPP . filterOutWsPP [scratchpadWorkspaceTag] $
        xmobarPP
          { ppOrder = \(ws : l : _) -> [l, ws]
          }
    )

myLayoutHook = tiled ||| Full
  where
    tiled = Tall nmaster delta ratio
      where
        nmaster = 1
        ratio = 1 / 2
        delta = 3 / 100

main :: IO ()
main =
  xmonad . withSB mySB . workspaceNamesEwmh . ewmh . docks $
    def
      { terminal = myTerminal,
        focusFollowsMouse = myFocusFollowsMouse,
        clickJustFocuses = myClickJustFocuses,
        borderWidth = myBorderWidth,
        modMask = myModMask,
        keys = myKeys,
        workspaces = myWorkspaces,
        handleEventHook = mempty,
        startupHook = myStartupHook,
        logHook = return (),
        layoutHook = myLayoutHook
      }
