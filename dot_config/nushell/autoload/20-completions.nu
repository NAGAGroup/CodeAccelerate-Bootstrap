# Completions + prompt.
#
# carapace, pixi, and starship each emit a Nushell init script. Rather than
# `source`-ing them at startup (source is parse-time, so a missing cache file
# would hard-error), we CACHE each one as its own gitignored autoload file:
#
#   autoload/90-carapace.nu   carapace external completer + bridges
#   autoload/91-pixi.nu       pixi subcommand completions
#   autoload/92-starship.nu   starship prompt
#
# Autoload simply skips files that don't exist, so a fresh machine (before the
# caches are generated) still starts cleanly. Regenerate anytime with
# `refresh-completions`; scripts/install.nu also runs it at bootstrap.
#
# CARAPACE_BRIDGES is set in 00-env.nu so it applies before the completer loads.

def refresh-completions [] {
    let dir = ($nu.default-config-dir | path join autoload)
    mkdir $dir
    if (which carapace | is-not-empty) {
        carapace _carapace nushell | save -f ($dir | path join 90-carapace.nu)
    }
    if (which pixi | is-not-empty) {
        pixi completion --shell nushell | save -f ($dir | path join 91-pixi.nu)
    }
    if (which starship | is-not-empty) {
        starship init nu | save -f ($dir | path join 92-starship.nu)
    }
    print "regenerated carapace/pixi/starship autoload files — restart nu to load"
}
