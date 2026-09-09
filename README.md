# Tmux Plugin -split status bar

This is an plugin that split stats bar into 2 parts (lines)

  `status-left / status-right` part - First line

  `window part` - Second line (the `window-second-line` branch)

This plugin provides function to hide status-left / status-right as well, if you want to focus, pure silence environment.

This plugin is compatible with Tmux plugin manager([TPM](https://github.com/tmux-plugins/tpm))

This pllugin should work with any themes well.

## Refresh cost and Oh my tmux! integration

Apply this plugin after the theme has finished setting its status formats.
It configures the layout when loaded or explicitly toggled; it does not need
a timer, a background polling process, or a command in the status text.
Unchanged option values are skipped, so repeated applications of the same
layout do not trigger tmux's option-change redraws. Format conversion uses
Bash substitutions instead of spawning four `sed` processes.

If an older Oh my tmux! configuration contains `#{split_statusbar_on}` in
`tmux_conf_theme_status_left`, remove that placeholder when switching to this
plugin. The framework converts it to a `#(...)` job that calls the **separate
function in `.tmux.conf.local`**, not this plugin's function. Updating this
repository alone does not change that copy. Calling a layout-changing function
from status rendering repeatedly writes global options and redraws clients.

Keep the two-line layout by loading this plugin once **after** theme setup,
including any asynchronous theme setup. For this branch, use:

```tmux
set -g @plugin 'tru2dagame/tmux-split-statusbar#window-second-line'
set -g @split-statusbar-mode 'on'
```

For a manual checkout, run its actual entrypoint after the theme is ready:

```tmux
run-shell '/path/to/tmux-split-statusbar/tmux-split-statusbar.tmux'
```

Bindings use that checkout's path, including paths containing spaces. Toggle
and hide commands do not reinstall bindings. Normal dynamic status text still
refreshes using tmux's status interval. Do not put the entrypoint itself inside
`status-left` or `status-right` as a replacement for the old function.

These changes address redundant work; they do not establish the cause of a
previous tmux crash or guarantee that verbose `tmux -v` logging is inexpensive.

### Verification

```sh
bash -n tmux-split-statusbar.tmux scripts/helpers.sh
```

The local integration test (kept outside the commit) uses a temporary private socket, an empty tmux config,
and a plugin copy under a path containing spaces. It checks layout ordering,
zero option writes on repeated application/loading, toggles, hide/restore,
explicit reload, and bindings. It never reloads the user's running server.
Python is required only for tests.

# Installation
## Installation with [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)
### Notice:

Due to using the command set -g**a** status-left / status-right

`And it would be better put "tmux-split-statusbar" config lines **AFTER** `status style like` setup !`


### Requirements:
Requirements 1 : Make sure set these config lines **AFTER** `theme plugin`

  (keep this plugin at the very bottom of tmux.conf)

  Better **JUST** before this line

  ```bash
  run -b '~/.tmux/plugins/tpm/tpm'
  ```

Requirements 2 : `tmux` version 3.0 (or higher), `bash`.

Add plugin to the list of TPM plugins in `.tmux.conf`:

    set -g @plugin 'charlietag/tmux-split-statusbar'

Hit `prefix + I` to fetch the plugin and source it.

Status bar should be splited now

## Manual Installation

Clone the repo:

    $ git clone https://github.com/charlietag/tmux-split-statusbar.git ~/clone/path

Add this line to the bottom of `.tmux.conf`:

    run-shell ~/clone/path/tmux-split-statusbar.tmux

Reload TMUX environment:

    # type this in terminal
    $ tmux source-file ~/.tmux.conf

Status bar should be splited now


# Examples

Status bar splited (on): double lines<br/>
![split-statusbar-mode-on](/screenshots/split-statusbar-mode-on.png)

Status bar splited (off): single line<br/>
![split-statusbar-mode-off](/screenshots/split-statusbar-mode-off.png)

Status bar hide (on)<br/>
![split-statusbar-hide-on](/screenshots/split-statusbar-hide-on.png)

Status bar hide (off)<br/>
![split-statusbar-hide-off](/screenshots/split-statusbar-hide-off.png)


# Customization

Here are all available options with their default values:

```bash
@split-statusbar-mode 'on'           # [ on | off]

@split-statusbar-bindkey '-n F11'    # [ M-s | -n F11 | ... ]
                                     # bindkey for toggle statusbar-mode
                                     # define yourself just like bind-key, default: M-s

@split-status-hide-bindkey '-n F12'  # [ M-d | -n F12 | ... ]
                                     # bindkey for status-left / status-right hiding
                                     # define yourself just like bind-key, default: M-d
```

Don't forget to reload tmux environment (`$ tmux source-file ~/.tmux.conf`)
after you do this.


# Usage

Sample config in ~/.tmux.conf

```bash
set -g @plugin 'charlietag/tmux-split-statusbar'
set -g @split-statusbar-mode 'on'                 # [ on | off]

set -g @split-statusbar-bindkey '-n F11'          # [ M-s | -n F11 | ... ]
                                                  # bindkey for toggle statusbar-mode
                                                  # define yourself just like bind-key, default: M-s

set -g @split-status-hide-bindkey '-n F12'        # [ M-d | -n F12 | ... ]
                                                  # bindkey for status-left / status-right hiding
                                                  # define yourself just like bind-key, default: M-d
```

# Also read

- [.tmux.conf](https://github.com/charlietag/tmux_settings/blob/master/tmux.conf) - Tmux configuration sample by CharlieTag

# Other goodies

- [tmux-themes](https://github.com/charlietag/tmux-themes) - simple colorful theme made by CharlieTag

# License

[MIT license](https://opensource.org/licenses/MIT)

# Change Log

* 2020/07/01
  * https://github.com/charlietag/tmux-split-statusbar/compare/v0.0.0...v0.0.1
    * fully compatible with https://github.com/tmux-plugins/tmux-continuum (auto-save-session in hide status mode)
    * add reload function to **reinitialize status bar** (for working with tmux themes like [charlietag/tmux-themes](https://github.com/charlietag/tmux-themes))
      * Use the following command to **reset status bar to new themes**

        ```bash
        ~/.tmux/plugins/tmux-split-statusbar/tmux-split-statusbar.tmux reload
        ```
* 2021/07/14
  * https://github.com/charlietag/tmux-split-statusbar/compare/v0.0.1...v0.0.2
    * Fix issue Unwanted characters in window status #1
      * https://github.com/charlietag/tmux-split-statusbar/issues/1
