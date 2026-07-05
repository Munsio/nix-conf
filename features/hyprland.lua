hl.config({
  general = {
    gaps_in = 10,
    gaps_out = 10,
  },
  decoration = {
    rounding = 10,
  },
  dwindle = {
    preserve_split = true,
  },
  misc = {
    disable_hyprland_logo = true,
  },
  input = {
    touchpad = {
      natural_scroll = true,
    },
  },
  gestures = {
    workspace_swipe_touch = true,
  },
})

hl.env("NIXOS_OZONE_WL", "1")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND", "wayland,x11,*")

hl.window_rule({ match = { class = "com.moonlight_stream.Moonlight" }, monitor = 1 })
hl.window_rule({ match = { class = ".*" }, idle_inhibit = "fullscreen" })

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

hl.bind("SUPER + Return", hl.dsp.exec_cmd("__TERMINAL__"))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + P", hl.dsp.window.pseudo())

hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))

hl.bind("SUPER + left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "d" }))

hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ workspace = "r+1" }))
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ workspace = "r-1" }))

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "r+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "r-1" }))
hl.bind("SUPER + CTRL + right", hl.dsp.focus({ workspace = "m+1" }))
hl.bind("SUPER + CTRL + left", hl.dsp.focus({ workspace = "m-1" }))

hl.bind("SUPER + ALT + left", hl.dsp.window.resize({ x = -20, y = 0 }))
hl.bind("SUPER + ALT + right", hl.dsp.window.resize({ x = 20, y = 0 }))
hl.bind("SUPER + ALT + up", hl.dsp.window.resize({ x = 0, y = -20 }))
hl.bind("SUPER + ALT + down", hl.dsp.window.resize({ x = 0, y = 20 }))

for i = 1, 10 do
  local ws = tostring(i % 10)
  hl.bind("SUPER + " .. ws, hl.dsp.focus({ workspace = i }))
  hl.bind("SUPER + SHIFT + " .. ws, hl.dsp.window.move({ workspace = i }))
end

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
