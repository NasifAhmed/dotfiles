from email import message_from_string
import os
import re
import socket
import subprocess

from libqtile import hook



from typing import List  # noqa: F401

from libqtile import bar, layout, widget

# import widgets and bar
from libqtile.widget.groupbox import GroupBox
from libqtile.widget.currentlayout import CurrentLayout
from libqtile.widget.window_count import WindowCount
from libqtile.widget.windowname import WindowName
from libqtile.widget.prompt import Prompt
from libqtile.widget.cpu import CPU
from libqtile.widget.memory import Memory
from libqtile.widget.net import Net
from libqtile.widget.systray import Systray
from libqtile.widget.clock import Clock
from libqtile.widget.spacer import Spacer
from libqtile.widget.volume import Volume


from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

# Importing colors.py file
from colors import gruvbox


@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser('~')
    subprocess.call([home + '/.config/qtile/autostart.sh'])




mod = "mod4"
terminal = guess_terminal()

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html

    # Launch browser
    Key([mod], "b", lazy.spawn('firefox'), desc="Launch browser"),
    Key([mod], "f", lazy.spawn('nautilus'), desc="Launch file manager"),
    Key([mod], "c", lazy.spawn('gnome-calculator'), desc="Launch calculator"),


    Key([mod], "m", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen mode"),
    Key([mod, "shift"], "f", lazy.window.toggle_floating(), desc="Toggle floating mode"),


    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(),
        desc="Move window focus to other window"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(),
        desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(),
        desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(),
        desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.shrink(),
        desc="Shrink main window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow(),
        desc="Grow main window to the right"),
    # Key([mod, "control"], "j", lazy.layout.grow_down(),
    #    desc="Grow window down"),
    # Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack"),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),

    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(),
        desc="Spawn a command using a prompt widget"),
]

groups = [
       Group('1', label="1"),
        Group('2', label="2"),
        Group('3', label="3"),
        Group('4', label="4"),
        Group('5', label="5"),
        Group('6', label="6")
]

for i in groups:
    keys.extend([
        # mod1 + letter of group = switch to group
        Key([mod], i.name, lazy.group[i.name].toscreen(),
            desc="Switch to group {}".format(i.name)),

        # mod1 + shift + letter of group = switch to & move focused window to group
        # Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=True),
        #   desc="Switch to & move focused window to group {}".format(i.name)),
        # Or, use below if you prefer not to switch to that group.
        # # mod1 + shift + letter of group = move focused window to group
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            desc="move focused window to group {}".format(i.name)),
    ])

layouts = [
    layout.MonadTall(ratio=0.6, border_focus=gruvbox['fg'], border_width=1, margin=10),
    layout.Max(),
    # Try more layouts by unleashing below layouts.
    # layout.Columns(border_focus_stack=['#d75f5f', '#8f3d3d'], border_width=2),
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font='JetBrainsMono NF',
    fontsize=15,
    padding=3,
    foreground=gruvbox['bg'],
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        top=bar.Bar(
            [
                Spacer(
                    length=5,
                ),
                GroupBox(
                    disable_drag=True,
                    active=gruvbox['fg'],
                    inactive=gruvbox['gray'],
                    highlight_method='line',
                    rounded=False,
                    block_highlight_text_color=gruvbox['bg'],
                    borderwidth=0,
                    highlight_color=gruvbox['fg'],
                    background=gruvbox['bg']
                ),
                Spacer(
                    length=5,
                ),
                

                Spacer(length=10),

                Prompt(
                    foreground=gruvbox['fg'],
                ),

                WindowName(
                    foreground=gruvbox['fg'],
                    padding=350
                ),
                Spacer(length=100),

                Systray(
                    padding=15,
                    background=gruvbox['bg']
                ),
                Spacer(length=10),

                Spacer(
                    length=1,
                    background=gruvbox['fg'],
                ),
                Spacer(
                    length=5,
                    background=gruvbox['blue']
                ),
                Net(
                    background=gruvbox['blue'],
                    format='{down} ↓↑ {up}'
                ),
                Spacer(
                    length=5,
                    background=gruvbox['blue']
                ),
                Spacer(
                    length=1,
                    background=gruvbox['fg'],
                ),

                # Volume
                Spacer(
                    length=1,
                    background=gruvbox['fg'],
                ),
                Spacer(
                    length=5,
                    background=gruvbox['green']
                ),
                Volume(
                    background=gruvbox['green']
                ),
                Spacer(
                    length=5,
                    background=gruvbox['green']
                ),
                Spacer(
                    length=1,
                    background=gruvbox['fg'],
                ),
                #----------------------------



                # Date and Time
                Spacer(
                    length=1,
                    background=gruvbox['fg'],
                ),
                Spacer(
                    length=5,
                    background=gruvbox['cyan'],
                ),
                Clock(
                    background=gruvbox['cyan'],
                    format='%I:%M %p'),
                Spacer(
                    length=5,
                    background=gruvbox['cyan'],
                ),
                Spacer(
                    length=1,
                    background=gruvbox['fg'],
                ),
                Spacer(
                    length=5,
                    background=gruvbox['dark-cyan'],
                ),
                Clock(
                    background=gruvbox['dark-cyan'],
                    format=' %Y-%m-%d %a'),
                Spacer(
                    length=5,
                    background=gruvbox['dark-cyan'],
                ),
                Spacer(
                    length=1,
                    background=gruvbox['fg'],
                ),
                #----------------------------------

                # CurrentLayout
                #Spacer(
                #    length=1,
                #    background=gruvbox['fg'],
                #),
                #Spacer(
                #    length=5,
                #    background=gruvbox['dark-blue'],
                #),
                #CurrentLayout(
                #    background=gruvbox['dark-blue'],
                #),
                #Spacer(
                #    length=5,
                #    background=gruvbox['dark-blue'],
                #),
                #Spacer( length=1,
                #    background=gruvbox['fg'],
                #),
                #---------------
            ],
            background=gruvbox['bg'],
            size=26,
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(float_rules=[
    # Run the utility of `xprop` to see the wm class and name of an X client.
    *layout.Floating.default_float_rules,
    Match(wm_class='confirmreset'),  # gitk
    Match(wm_class='makebranch'),  # gitk
    Match(wm_class='maketag'),  # gitk
    Match(wm_class='ssh-askpass'),  # ssh-askpass
    Match(title='branchdialog'),  # gitk
    Match(title='pinentry'),  # GPG key password entry
])
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D" 
