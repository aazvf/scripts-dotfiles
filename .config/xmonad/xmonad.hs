import qualified Data.Map                             as M
import           Data.Ratio
import           Graphics.X11.ExtraTypes.XF86
import           System.Exit
import           XMonad
import           XMonad.Actions.CycleWS
import           XMonad.Actions.CycleWorkspaceByScreen
import           XMonad.Actions.DynamicProjects
import qualified XMonad.Actions.DynamicWorkspaceOrder as DO
import           XMonad.Actions.DynamicWorkspaces
import           XMonad.Actions.FloatSnap
import           XMonad.Actions.RotSlaves
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Hooks.Place
import           XMonad.Hooks.SetWMName
import           XMonad.Hooks.WorkspaceHistory (workspaceHistoryHook)
import           XMonad.Layout.Accordion
import           XMonad.Layout.Circle
import           XMonad.Layout.Cross
import           XMonad.Layout.Gaps
import           XMonad.Layout.Grid
import           XMonad.Layout.Hidden
import           XMonad.Layout.Mosaic
import           XMonad.Layout.OneBig
import           XMonad.Layout.PerWorkspace
import           XMonad.Layout.PerScreen
import           XMonad.Layout.ResizableTile
import           XMonad.Layout.Spacing
import           XMonad.Layout.Spiral
import           XMonad.Prompt.AppendFile
import qualified XMonad.StackSet                      as W
import           XMonad.Util.ActionCycle

------------------------------------------------------------------------
-- "Projects" enable specific layouts and auto launching apps for workspaces  
--

projects :: [Project]

codingProject = Project
    { projectName      = "coding"
    , projectDirectory = "/mnt/slowdata/projects/current"
    , projectStartHook = Just $ do
        spawn "code"
        repeatAction 2 (spawn "terminator")
    }

twitchProject = Project
    { projectName      = "twitch"
    , projectDirectory = "~"
    , projectStartHook = Just $ do
        repeatAction
            4
            (spawn "env GTK_THEME=Equilux-compact firefox -new-window https://www.twitch.tv/directory/following/live")
    }
projects = [codingProject, twitchProject]

myWorkspaces = ["z", "x", "c", "v", "a", "s", "d", "f", "q", "w", "e", "r", "b", "t", "g", "y", "u", "i", "n", "m"]

------------------------------------------------------------------------
-- Helper functions
--

-- Repeat an action
repeatAction 0 _      = return ()
repeatAction n action = do
    action
    repeatAction (n - 1) action

-- Make app floating and centered on screen
toggleFull = withFocused
    (\windowId -> do
        floats <- gets (W.floating . windowset)
        if windowId `M.member` floats
            then withFocused $ windows . W.sink
            else withFocused $ windows . (flip W.float $ W.RationalRect 0.1 0.1 0.8 0.8)
    )

-- Move status bar/panel to top
usePanelTop = sequence_
    [ broadcastMessage $ setGaps [(U, gapPanel), (D, gapEdge), (L, gapEdge), (R, gapEdge)]
    , spawn "~/_scripts/launch/panel-top.sh"
    ]

-- Move status bar/panel to bottom
usePanelBottom = sequence_
    [ broadcastMessage $ setGaps [(U, gapEdge), (D, gapPanel), (L, gapEdge), (R, gapEdge)]
    , spawn "~/_scripts/launch/panel-bottom.sh"
    ]

-- Gaps around apps/edge that we can change later with keybinds
gutter = 100
modGap side method amount = sendMessage $ method amount side
growGap side = modGap side IncGap gutter
shrinkGap side = modGap side DecGap gutter
sides = [U, R, D, L]
growGaps = sequence_ $ map growGap sides
shrinkGaps = sequence_ $ map shrinkGap sides
toggleGutter = cycleAction "toggleGutter" [growGaps, shrinkGaps]

-- Restart xmonad and exec autostart
restartXmonad :: X ()
restartXmonad = sequence_ [spawn "~/.config/xmonad/autostart", restart "xmonad" True]

------------------------------------------------------------------------
-- Keyboard Bindings
--

-- map modmask to something more human readable
_alt = modMask
_win = mod4Mask
_shift = shiftMask
_ctrl = controlMask

myKeys conf@(XConfig { XMonad.modMask = _alt }) =
    M.fromList
        $
        -- App launchers & menus
           [ ((_alt .|. _shift, xK_Return), spawn "terminator") -- terminal
           , ((_alt, xK_space), spawn "~/_scripts/launch/rofi.sh") -- rofi launcher
           , ((_alt, xK_p), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"") -- dmenu launcher
           , ((_win, xK_1), spawn "nixnote2")
           , ( (_win, xK_2)
             , spawn
                 "env GTK_THEME=Equilux-compact ~/Downloads/ungoogled/ungoogled-chromium_104.0.5112.102-1.1_linux/chrome --process-per-site"
             )
           , ((_win, xK_3), spawn "env GTK_THEME=Equilux-compact firefox")
           , ((_win, xK_4), spawn "env GTK_THEME=Equilux-compact chromium-browser --process-per-site")
           , ( (_win, xK_5)
             , spawn "env GTK_THEME=Equilux-compact firefox -new-window https://www.twitch.tv/directory/following/live"
             )
           , ((_win, xK_6), spawn "keepassxc")
           , ((_win, xK_7), spawn "geany")
           ]

        -- Screen Swap
        ++ [ ((_win, xK_Right)           , swapNextScreen) -- swap all apps with next screen
           , ((_win, xK_Left)            , swapPrevScreen) -- swap all apps with prev screen
           , ((_win .|. _shift, xK_Right), shiftNextScreen) -- move app to next screen
           , ((_win .|. _shift, xK_Left) , shiftPrevScreen) -- move app to prev screen
           ]

        -- Workspaces
        ++ [ ((_win, xK_Up)          , toggleWS) -- Toggle between last two workspaces
           , ((_alt .|. _shift, xK_m), withWorkspace def (windows . W.shift)) -- move app to workspace
           , ((_alt, xK_q)           , windows $ W.greedyView "q") -- view specific workspaces by name
           , ((_alt, xK_w)           , windows $ W.greedyView "w")
           , ((_alt, xK_e)           , windows $ W.greedyView "e")
           , ((_alt, xK_r)           , windows $ W.greedyView "r")
           , ((_alt, xK_t)           , windows $ W.greedyView "t")
           , ((_alt, xK_y)           , windows $ W.greedyView "y")
           , ((_alt, xK_u)           , windows $ W.greedyView "u")
           , ((_alt, xK_i)           , windows $ W.greedyView "i")
           , ((_alt, xK_a)           , windows $ W.greedyView "a")
           , ((_alt, xK_s)           , windows $ W.greedyView "s")
           , ((_alt, xK_d)           , windows $ W.greedyView "d")
           , ((_alt, xK_f)           , windows $ W.greedyView "f")
           , ((_alt, xK_g)           , windows $ W.greedyView "g")
           , ((_alt, xK_z)           , windows $ W.greedyView "z")
           , ((_alt, xK_x)           , windows $ W.greedyView "x")
           , ((_alt, xK_c)           , windows $ W.greedyView "c")
           , ((_alt, xK_v)           , windows $ W.greedyView "v")
           , ((_alt, xK_b)           , windows $ W.greedyView "b")
           , ((_alt, xK_n)           , windows $ W.greedyView "n")
           , ((_alt, xK_m)           , windows $ W.greedyView "m")
           , ((_win, xK_a)           , switchProject twitchProject) -- switch to my "twitch" workspace
           , ((_win, xK_s)           , switchProject codingProject) -- switch to my "coding" workspace
           , ((_win, xK_bracketleft), (cycleWorkspaceOnCurrentScreen [xK_Super_L] xK_bracketright xK_bracketleft)) -- cycle through workspaces recently used on screen
           , ((_win, xK_bracketright), (cycleWorkspaceOnCurrentScreen [xK_Super_L] xK_bracketright xK_bracketleft)) -- cycle back through workspaces for screen
           ]

        -- Layouts
        ++ [ ((_win, xK_m)    , toggleGutter) -- toggle space around screen
           , ((_win, xK_space), sendMessage NextLayout) -- use next layout
           , ( (_alt .|. _win .|. _shift, xK_space)
             , sequence_ [cycleAction "gapsToggle" [usePanelTop, usePanelBottom], refresh]
             ) -- toggle status bar position between top/bottom
           , ((_alt .|. _win, xK_space)  , sendMessage $ ToggleGaps) -- toggle reserved space for status bar
           , ((_alt .|. _shift, xK_space), setLayout $ XMonad.layoutHook conf) -- reset layout
           ]

        -- Clipboard
        ++ [ ((_win .|. _ctrl, xK_c) , spawn "~/_scripts/clipboard/save.sh") -- save current clipboard as snippet
           , ((_win, xK_v)           , spawn "~/_scripts/clipboard/prompt.sh") -- prompt to use saved snippet
           , ((_alt, xK_apostrophe)  , spawn "~/_scripts/clipboard/prompt.sh")
           , ((_win .|. _shift, xK_v), spawn "~/_scripts/clipboard/remove.sh") -- remove item from snippets
           , ((_win .|. _ctrl, xK_v) , appendFilePrompt def "~/.clipboard") -- add specic text to snippets
           , ((_win, xK_t)           , spawn "~/_scripts/clipboard/timestamp.sh") -- put timestamp in clipboard
           ]

        -- Windows
        ++ [ ((_win, xK_x)               , windows $ W.shiftMaster . W.focusUp) -- rotate all
           , ((_win, xK_c)               , rotSlavesUp) -- rotate slaves
           , ((_win, xK_f)               , toggleFull) -- float and center
           , ((_alt .|. _shift, xK_c)    , kill)
           , ((_alt, xK_Escape)          , kill)
           , ((_alt, xK_Tab)             , windows W.focusDown) -- focux next
           , ((_alt, xK_j)               , windows W.focusDown) -- focus next
           , ((_alt, xK_k)               , windows W.focusUp) -- focus previous
           , ((_alt .|. _shift, xK_m)    , windows W.focusMaster) -- focus on master 
           , ((_alt, xK_Return)          , windows W.swapMaster) -- swap focused with master
           , ((_alt .|. _shift, xK_j)    , windows W.swapDown) -- swap focused with next
           , ((_alt .|. _shift, xK_k)    , windows W.swapUp) -- swap focused with previous
           , ((_alt, xK_h)               , sendMessage Shrink) -- shrink master
           , ((_alt, xK_l)               , sendMessage Expand) -- expand master
           , ((_alt .|. _shift, xK_t)    , withFocused $ windows . W.sink) -- make window tiled
           , ((_alt, xK_comma)           , sendMessage (IncMasterN 1)) -- increase master count
           , ((_alt .|. _shift, xK_comma), sendMessage (IncMasterN (-1))) -- decrease master count
           , ((_alt, xK_slash)           , withFocused hideWindow) -- minimize
           , ((_alt, xK_period)          , popOldestHiddenWindow) -- restore minimized
           ]

        -- Screens
        ++ [ ((_win, xK_q), spawn "~/_scripts/xrandr/triple-dp.sh") -- use three screens
           , ((_win, xK_u), spawn "~/_scripts/xrandr/hdmi-only.sh") -- use one hdmi screen
           , ((0, xK_Home), spawn "~/_scripts/screen-toggle.sh") -- toggle screens on/off
           ]
        -- Focus screens with win+ wer
        ++ [ ((m .|. _win, key), screenWorkspace sc >>= flip whenJust (windows . f))
           | (key, sc) <- zip [xK_w, xK_e, xK_r] [0 ..]
           , (f  , m ) <- [(W.view, 0), (W.shift, shiftMask)]
           ]

        -- Desktop
        ++ [ ((_win, xK_h)          , spawn "~/_scripts/launch/conky-help.sh") -- show help message
           , ((_win, xK_j)          , spawn "~/_scripts/launch/conky-desktops.sh") -- show list of apps by workspace
           , ((_win .|. _ctrl, xK_t), spawn "~/_scripts/launch/panel-restart.sh") -- restart panel + status bar
           , ((_win, xK_b)          , spawn "~/_scripts/background.sh") -- set new random background
           ]

        -- Xmonad restart
        ++ [ ((_alt .|. _shift, xK_0), io (exitWith ExitSuccess)) -- quit xmonad
           , ((_alt, xK_0)           , restartXmonad) -- restart xmonad
           , ((_alt, xK_Insert)      , restart "xmonad" True) -- alternate restart xmonad
           ]

        -- Keyboard setup
        ++ [((_alt, xK_semicolon), spawn "~/_scripts/keyboard.sh")] --unused?

        -- Remote control
        ++ [ ((_win, xK_k)                , spawn "~/_scripts/remap-remote.sh") -- set up keybinds if unplugged
           , ((0, xF86XK_PowerOff)        , spawn "~/_scripts/screen-toggle.sh") -- power on/off screens
           , ((0, xF86XK_HomePage)        , spawn "~/_scripts/background.sh") -- new background
           , ((0, xF86XK_AudioPrev)       , spawn "~/remote-keybinds/music/prev.sh") -- up, previous
           , ((0, xF86XK_ApplicationLeft) , spawn "~/remote-keybinds/music/skipback.sh") -- left, skip back
           , ((0, xF86XK_Go)              , spawn "~/remote-keybinds/music/startpause.sh") -- ok, startpause
           , ((0, xF86XK_ApplicationRight), spawn "~/remote-keybinds/music/skipforward.sh")  -- right, skip forward
           , ((0, xF86XK_AudioNext)       , spawn "~/remote-keybinds/music/next.sh") -- down, next
           , ((0, xF86XK_Book)            , spawn "~/_scripts/background.sh") -- bars, skip back
           , ((0, xF86XK_Close)           , spawn "~/_scripts/background.sh") -- new backgrounds
           , ((0, xF86XK_AudioLowerVolume), spawn "~/remote-keybinds/music/volumedown.sh")
           , ((0, xF86XK_AudioRaiseVolume), spawn "~/remote-keybinds/music/volumeup.sh")
           ]

        -- Media controls
        ++ [ ((_win, xK_minus)     , spawn "~/remote-keybinds/voldown.sh")
           , ((_win, xK_equal)     , spawn "~/remote-keybinds/volup.sh")
           , ((0, xF86XK_AudioPlay), spawn "~/remote-keybinds/music/startpause.sh")
           , ((0, xF86XK_AudioMute), spawn "~/remote-keybinds/volmute.sh")
           ]

        -- Screenshots
        ++ [ ((_alt, xK_o), spawn "~/_scripts/screenshot.sh") -- take screenshot of selected area
           , ((_win, xK_o), spawn "~/_scripts/screenshot.sh")
           ]

        -- Check vpn status
        ++ [((_win, xK_i), spawn "~/_scripts/vpn.sh check")]


------------------------------------------------------------------------
-- Mouse bindings
--
myMouseBindings (XConfig { XMonad.modMask = _alt }) =
    M.fromList
        $
        -- drags (1 = left, 2 = middle, 3 = right)
           [ ((_alt, button1), (\w -> focus w >> mouseMoveWindow w >> afterDrag (windows $ W.sink w))) -- move then tile
           , ((_win, button1), (\w -> focus w >> mouseMoveWindow w >> afterDrag (snapMagicMove (Just 50) (Just 50) w))) -- move
           , ((_alt, button2), (\w -> focus w >> mouseMoveWindow w)) -- move
           , ((_alt, button3), (\w -> focus w >> mouseResizeWindow w)) -- resize 
           , ((_win, button3), (\w -> focus w >> windows W.swapMaster)) -- move app to master
           ]
        -- side buttons (8 = down, 9 = up)
        ++ [ ((0, 8)   , (\_ -> DO.moveToGreedy Next (hiddenWS :&: Not emptyWS))) -- next workspace
           , ((0, 9)   , (\_ -> DO.moveToGreedy Prev (hiddenWS :&: Not emptyWS))) -- prev workspace
           , ((_alt, 8), (\_ -> DO.moveToGreedy Next emptyWS)) -- next empty workspace
           , ((_alt, 9), (\_ -> DO.moveToGreedy Prev emptyWS)) -- prev empty workspace
           ]
        -- scrolls (4 = down, 5 = up)
        ++ [ ((_alt, button4)           , (\_ -> DO.moveToGreedy Next (hiddenWS :&: Not emptyWS))) -- next active workspace
           , ((_alt, button5)           , (\_ -> DO.moveToGreedy Prev (hiddenWS :&: Not emptyWS))) -- prev active workspace
           , ((_alt .|. _shift, button4), (\_ -> shiftToNext >> nextWS)) -- move app next active workspace
           , ((_alt .|. _shift, button5), (\_ -> shiftToPrev >> prevWS)) -- move app prev active workspace
           , ((_alt .|. _ctrl, button4) , (\_ -> DO.moveTo Next emptyWS)) -- move app next empty workspace
           , ((_alt .|. _ctrl, button5) , (\_ -> DO.moveTo Prev emptyWS)) -- move app prev empty workspace
           ]

------------------------------------------------------------------------
-- Layouts

goldenRatio = toRational (2 / (1 + sqrt 5 :: Double)) -- golden, thx Octoploid
spiralLayout = spiral goldenRatio
defaultTallLayout = Mirror $ ResizableTall 1 (3 / 100) (1 / 2) []

gapBetween = 3 -- between apps when > 1 app
gapEdge = 2 -- between apps and screen
gapBar = 24 -- reserved for status bar / systray
gapPanel = gapBar + gapEdge -- reserved space for status bar AND gaps


-- defines the "layouts" - how the windows should be arranged
-- I think it works like this -
-- layouts = modifiers (list of layouts)
-- layouts = modifier $ modifier $ modifier (layout type ||| layout type) where variable = value

layouts =
    avoidStruts
        $ spacingRaw
              True
              (Border 0 gapBetween 0 gapBetween)
              False
              (Border gapBetween gapBetween gapBetween gapBetween)
              True
        $ onWorkspace "coding" tiled
        $ onWorkspace "twitch" Grid
        $ hiddenWindows
        $ (   spiralLayout
          ||| tiled
          ||| Grid
          ||| (mosaic 2 [3, 2])
          ||| (OneBig (3 / 4) (3 / 4))
          ||| (Mirror tiled)
          ||| defaultTallLayout
          ||| Accordion
          ||| Circle
          ||| simpleCross
          ||| Full
          )
    where
        tiled   = Tall nmaster delta ratio
        nmaster = 1
        ratio   = 0.75
        delta   = 3 / 100


-- Now that we have the layouts, we can conditionally apply modifiers based on the screen width.
-- "layoutsWithGaps" is a copy of our layouts but with space reserved for the status bar.
-- This is the layout we'll normally use, but if the screen width is more than 1920 then use the layouts without the preserved space.
-- Why? I have 3 monitors, two 1920s and a one 4k above. This means I can ensure the bottom two screens have reserved space, but the 4k above
-- will not have preserved space and use the full screen.

layoutsWithGaps = gaps [(U, gapEdge), (D, gapPanel), (L, gapEdge), (R, gapEdge)] $ layouts
myLayoutHook = ifWider 1920 layouts layoutsWithGaps

------------------------------------------------------------------------
-- Window float and positioning rules:

myManageHook = manageDocks <+> composeAll
    [ title ^? "DevTools" --> doRectFloat (W.RationalRect 0 0.48 (1 % 2) (1 % 2))
    , placeHook (withGaps (2, 16, 26, 16) (smart (0.5, 0.5)))
    , className =? "MPlayer" --> doFloat
    , className =? "Gimp" --> doFloat
    , className =? "xlunch" --> doFloat
    , className =? "Xmessage" --> doFloat
    , className =? "Lxappearance" --> doFloat
    , className =? "Pavucontrol" --> doFloat
    , title =? "Open Workspace from File" --> doFloat -- vscode dialog
    , title =? "Open Folder" --> doFloat -- vscode dialog
    , title =? "Open File" --> doFloat -- vscode dialog
    , isDialog --> doFloat
    , title =? "Terminator Preferences" --> doFloat
    , className =? "Gnome-screenshot" --> doFloat
    , (stringProperty "WM_NAME" =? "" <&&> className =? "TeamViewer") --> doIgnore
    , resource =? "desktop_window" --> doIgnore
    , resource =? "kdesktop" --> doIgnore
    ]

------------------------------------------------------------------------
-- Other Xmonad hooks

-- workspaceHistoryHook
-- myLogHook = return ()

-- Pretend to be lxqt and run our scripts on startup.
myStartupHook :: X ()
myStartupHook = do
    setWMName "lxqt"
    spawn "~/.xmonad/autostart"

------------------------------------------------------------------------
-- Config xmoanad and launch
defaults = def
    { terminal           = "terminator"
    , focusFollowsMouse  = True
    , clickJustFocuses   = False
    , borderWidth        = 0
    , modMask            = mod1Mask
    , workspaces         = myWorkspaces
    , normalBorderColor  = "#373737"
    , focusedBorderColor = "#91AF5E"
    , keys               = myKeys
    , mouseBindings      = myMouseBindings
    , layoutHook         = myLayoutHook
    , manageHook         = myManageHook
    , logHook            = workspaceHistoryHook
    , startupHook        = myStartupHook
    }

main = xmonad $ ewmhFullscreen $ (dynamicProjects projects) $ ewmh defaults
