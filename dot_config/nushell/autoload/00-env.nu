# Environment variables and PATH. Numeric prefix 00 = loads first, so every
# later autoload file and the prompt see a fully-populated PATH.

$env.EDITOR = "nvim"

# carapace bridges completion specs from other shells (see 20-completions.nu).
$env.CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense"

use std/util "path add"

# `path add` PREPENDS, so the last add wins. ~/.pixi/bin is added last on
# purpose: the pixi global shims take priority over everything else.
path add ~/go/bin
path add ~/bin
path add ~/.cargo/bin
path add ~/.opencode/bin
path add ~/.local/bin
# Not for node/npm/bun themselves (those are pixi shims) — this is where
# `npm install -g ...` drops global bins, which a lot of tooling expects to find.
path add ~/.pixi/envs/nodejs
path add ~/.pixi/envs/nodejs/bin
path add ~/.pixi/bin
