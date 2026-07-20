# config.nu — Nushell settings ($env.config only).
#
# On Nushell 0.101+ the recommended layout is config.nu for settings plus an
# autoload/ directory for everything else (env vars, PATH, aliases, completions,
# prompt). Files in autoload/ load automatically, in alphabetical order, AFTER
# this file — hence the numeric prefixes there control ordering.
#
#   autoload/00-env.nu          env vars + PATH
#   autoload/10-aliases.nu      coreutils aliases
#   autoload/20-completions.nu  carapace + pixi (from cache)
#   autoload/30-starship.nu     prompt (from cache)
#   autoload/secrets.nu         machine-local, gitignored

# Open `config nu` / `config env` in nvim (matches $env.EDITOR in 00-env.nu).
$env.config.buffer_editor = "nvim"

# The startup banner is noise on every new pane/tab.
$env.config.show_banner = false
