# dots.nu — cross-platform dotfiles manager (Nushell)
#
# Requires uutils-coreutils on PATH (provides `ln`). Nushell has no native
# symlink-creation primitive on any platform, and on Windows `ln` is not on
# PATH by default. uutils' `ln -s` calls Rust's std symlink APIs, which pass
# SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE — so with Developer Mode on you
# get real, unprivileged symlinks on Windows too. No cmd.exe, no mklink, no
# junction fallback.
#
#   Install: scoop install uutils-coreutils   (or `cargo install coreutils`)
#
# Commands:
#   sync [-n]                       create/repair links from dots.toml
#   status [-n]                     show link state
#   unlink [-n]                     remove only links pointing at managed sources
#   add <real-path> [-p plats] [-n] copy a real path into the repo, link it back
#   link <src> <real-path> [...]    register an existing repo source at a target
#   remove <target> [-n]            unmanage: move files back to the system
#   purge <target> [-n]             unmanage AND delete both link and repo source
#   migrate [-n]                    Windows one-time: convert legacy junctions to symlinks

# ── Platform / repo helpers ────────────────────────────────────────────────

# Aliases for uutils-coreutils (pixi-installed multi-call binary)
# Source this file from your nushell config, e.g.:
#   source ~/dotfiles/coreutils-aliases.nu

alias arch = coreutils arch
alias b2sum = coreutils b2sum
alias base32 = coreutils base32
alias base64 = coreutils base64
alias basename = coreutils basename
alias basenc = coreutils basenc
alias cat = coreutils cat
alias cksum = coreutils cksum
alias comm = coreutils comm
alias cp = coreutils cp
alias csplit = coreutils csplit
alias cut = coreutils cut
alias date = coreutils date
alias dd = coreutils dd
alias df = coreutils df
alias dir = coreutils dir
alias dircolors = coreutils dircolors
alias dirname = coreutils dirname
alias du = coreutils du
alias c-echo = coreutils echo
alias c-env = coreutils env
alias expand = coreutils expand
alias expr = coreutils expr
alias factor = coreutils factor
alias fmt = coreutils fmt
alias fold = coreutils fold
alias head = coreutils head
alias hostname = coreutils hostname
alias join = coreutils join
alias link = coreutils link
alias ln = coreutils ln
alias c-ls = coreutils ls
alias md5sum = coreutils md5sum
alias mkdir = coreutils mkdir
alias mktemp = coreutils mktemp
alias more = coreutils more
alias mv = coreutils mv
alias nl = coreutils nl
alias nproc = coreutils nproc
alias numfmt = coreutils numfmt
alias od = coreutils od
alias paste = coreutils paste
alias pathchk = coreutils pathchk
alias pr = coreutils pr
alias printenv = coreutils printenv
alias c-printf = coreutils printf
alias ptx = coreutils ptx
alias pwd = coreutils pwd
alias readlink = coreutils readlink
alias realpath = coreutils realpath
alias rm = coreutils rm
alias rmdir = coreutils rmdir
alias seq = coreutils seq
alias sha1sum = coreutils sha1sum
alias sha224sum = coreutils sha224sum
alias sha256sum = coreutils sha256sum
alias sha384sum = coreutils sha384sum
alias sha512sum = coreutils sha512sum
alias shred = coreutils shred
alias shuf = coreutils shuf
alias c-sleep = coreutils sleep
alias sort = coreutils sort
alias split = coreutils split
alias stdbuf = coreutils stdbuf
alias sum = coreutils sum
alias sync = coreutils sync
alias tac = coreutils tac
alias tail = coreutils tail
alias tee = coreutils tee
alias c-test = coreutils test
alias touch = coreutils touch
alias tr = coreutils tr
alias truncate = coreutils truncate
alias tsort = coreutils tsort
alias tty = coreutils tty
alias uname = coreutils uname
alias unexpand = coreutils unexpand
alias uniq = coreutils uniq
alias unlink = coreutils unlink
alias vdir = coreutils vdir
alias wc = coreutils wc
alias whoami = coreutils whoami
alias c-yes = coreutils yes

# '[' is the "test" alias in POSIX shells; nushell doesn't parse bare '['
# as a command word well, so it's given a quoted alias name here too:
alias '[' = coreutils '['

def get_platform [] {
    if $nu.os-info.name == "windows" { "win-64" } else { "linux-64" }
}

const dots_nu = path self
def get_repo_root [] {
    $dots_nu | path dirname | path dirname
}

# ── Link primitives (uniform across platforms) ─────────────────────────────

# Create a symlink. `-n` (no-dereference) ensures that if `target` is an
# existing symlink to a directory we replace the link rather than creating a
# new link inside the directory it points to.
def create_link [source: string, target: string] {
    let result = (do { ln -sfn $source $target } | complete)
    if $result.exit_code != 0 {
        error make { msg: $"Failed to link ($target) -> ($source): ($result.stderr)" }
    }
}

# True if the link at `link` resolves to the same real path as `source`.
# Compares fully-resolved paths (path expand follows symlinks), so it is
# immune to separator style, relative vs absolute targets, and — on Windows —
# case and even legacy junctions. Managed sources always exist, so the link is
# never broken when this is called.
def points_to [link: string, source: string] {
    let resolved = ($link | path expand)
    let src = ($source | path expand)
    if $nu.os-info.name == "windows" {
        ($resolved | str lowercase) == ($src | str lowercase)
    } else {
        $resolved == $src
    }
}

# Case/separator-aware equality for two path-like strings (no symlink follow).
def paths_equal [a: string, b: string] {
    let ea = ($a | path expand --no-symlink)
    let eb = ($b | path expand --no-symlink)
    if $nu.os-info.name == "windows" {
        ($ea | str lowercase) == ($eb | str lowercase)
    } else {
        $ea == $eb
    }
}

# Windows only: true if `path` is a *junction* (mount-point reparse point).
# Distinguishes junctions from symlinks by reparse tag (junction =
# IO_REPARSE_TAG_MOUNT_POINT 0xa0000003), so it never misfires on a real
# symlink even if `path type` were to misreport one.
def is_junction [path: string] {
    if $nu.os-info.name != "windows" {
        return false
    }
    let win = ($path | str replace -a '/' '\')
    let r = (do { fsutil reparsepoint query $win } | complete)
    if $r.exit_code != 0 {
        return false
    }
    ($r.stdout | str lowercase | str contains "0xa0000003")
}

# Ensure a target path is clear so a fresh link can be created.
#   correct symlink -> returns "linked" (caller should skip)
#   stale symlink   -> removed, returns "clear"
#   real file/dir   -> moved to <target>.bak, returns "clear"
# Refuses to overwrite an existing .bak, and refuses to touch a legacy
# junction (which reports as a directory but holds no data of its own).
def prepare_target [target: string, source: string, dry_run: bool] {
    if not ($target | path exists) {
        return "clear"
    }
    let ltype = ($target | path type)
    if $ltype == "symlink" {
        if (points_to $target $source) {
            return "linked"
        }
        if $dry_run {
            print $"[dry-run] would remove stale link: ($target)"
        } else {
            rm ($target | str trim --right --char '/')
            print $"[removed stale link] ($target)"
        }
        return "clear"
    }
    # Not a Nushell-recognized symlink. On Windows it may be a legacy junction.
    if $nu.os-info.name == "windows" and (is_junction $target) {
        error make { msg: $"($target) is a legacy junction. Run `migrate` to convert managed junctions to symlinks first." }
    }
    # Real file or directory: back it up for real. Use .bak if free, otherwise
    # fall back to a timestamped name so a prior backup is never clobbered and
    # we never hard-fail on an existing one.
    let bak = if not (($target + ".bak") | path exists) {
        $target + ".bak"
    } else {
        $target + ".bak." + (date now | format date "%Y%m%d-%H%M%S")
    }
    if $dry_run {
        print $"[dry-run] would backup: ($target) -> ($bak)"
    } else {
        mv $target $bak
        print $"[backup] ($target) -> ($bak)"
    }
    return "clear"
}

# ── Path encoding ──────────────────────────────────────────────────────────

# Encode a real absolute path to a repo-relative source path (forward slashes,
# portable across platforms). Leading dot of each segment becomes `dot_` so the
# file is not hidden in the repo.
#   ~/.config/nushell -> dot_config/nushell
#   ~/.tmux.conf      -> dot_tmux.conf
#   ~/bin/tool        -> bin/tool
def encode_path [real_path: string] {
    let expanded = ($real_path | path expand --no-symlink)
    let home = ($nu.home-dir)
    let rel = try {
        $expanded | path relative-to $home
    } catch {
        error make { msg: $"Path ($real_path) is not under home directory ($home)" }
    }
    let segments = ($rel | path split)
    let encoded = ($segments | each { |seg|
        if ($seg | str starts-with ".") {
            "dot_" + ($seg | str replace --regex '^\.+' "")
        } else {
            $seg
        }
    })
    $encoded | str join "/"
}

# Convert an expanded absolute path under $HOME to a portable ~/... path.
def to_tilde_path [expanded: string] {
    "~/" + ($expanded | path relative-to $nu.home-dir | str replace -a '\' '/')
}

# ── Spec loading ───────────────────────────────────────────────────────────

def filter_links [links: list<record>, platform: string] {
    $links | where { |entry|
        if "platforms" in $entry {
            $platform in $entry.platforms
        } else {
            true
        }
    }
}

def load_spec [] {
    let repo = (get_repo_root)
    let platform = (get_platform)
    let spec_file = ($repo | path join "dots.toml")
    if not ($spec_file | path exists) {
        error make { msg: $"dots.toml not found at ($spec_file)" }
    }
    let spec = (open $spec_file)
    let links = if "links" in $spec { $spec.links } else { [] }
    let active = (filter_links $links $platform)
    { repo: $repo, platform: $platform, spec_file: $spec_file, links: $links, active: $active }
}

# Rewrite dots.toml dropping [[links]] blocks whose source is in the removal
# set, preserving comments and formatting of everything else.
def rewrite_spec_without [
    spec_file: string,
    sources_to_remove: list<string>,
    dry_run: bool,
    verb: string,
    target_path: string,
] {
    let raw = (open --raw $spec_file)
    let lines = ($raw | lines)
    mut preamble = []
    mut blocks = []
    mut current_block = []
    mut in_block = false
    for line in $lines {
        let trimmed = ($line | str trim)
        if $trimmed == "[[links]]" {
            if $in_block {
                $blocks = ($blocks | append [($current_block | str join "\n")])
            }
            $current_block = [$line]
            $in_block = true
        } else if $in_block {
            $current_block = ($current_block | append $line)
        } else {
            $preamble = ($preamble | append $line)
        }
    }
    if $in_block {
        $blocks = ($blocks | append [($current_block | str join "\n")])
    }
    let kept = ($blocks | where { |block|
        not ($sources_to_remove | any { |s| $block | str contains $"source = \"($s)\"" })
    })
    let preamble_text = ($preamble | str join "\n" | str trim --right)
    let blocks_text = ($kept | each { |b| $b | str trim } | str join "\n\n")
    let new_content = if ($kept | length) > 0 {
        $preamble_text + "\n\n" + $blocks_text + "\n"
    } else {
        $preamble_text + "\n"
    }
    if $dry_run {
        print $"[dry-run] would update dots.toml: remove entry for target ($target_path)"
    } else {
        $new_content | save --force $spec_file
        print $"[($verb)] ($target_path) from dots.toml"
    }
}

# ── Commands ───────────────────────────────────────────────────────────────

# Create symlinks based on dots.toml. Use --dry-run (-n) to preview.
export def sync [
    --dry-run (-n)  # Print actions without executing
] {
    let ctx = (load_spec)
    for entry in $ctx.active {
        let source = ($ctx.repo | path join $entry.source)
        let target = ($entry.target | path expand --no-symlink)
        if not ($source | path exists) {
            print $"[skip] source does not exist: ($source)"
            continue
        }
        let state = (prepare_target $target $source $dry_run)
        if $state == "linked" {
            print $"[ok] already linked: ($target)"
            continue
        }
        let parent = ($target | path dirname)
        if not $dry_run {
            if not ($parent | path exists) {
                mkdir $parent
            }
        }
        if $dry_run {
            print $"[dry-run] would link: ($source) -> ($target)"
        } else {
            create_link $source $target
            print $"[linked] ($source) -> ($target)"
        }
    }
}

# Show current symlink status. --dry-run (-n) accepted for CLI consistency.
export def status [
    --dry-run (-n)  # Accepted for CLI consistency; status is always read-only
] {
    if $dry_run {
        print "[dry-run] status is read-only, showing current state:"
    }
    let ctx = (load_spec)
    $ctx.active | each { |entry|
        let source = ($ctx.repo | path join $entry.source)
        let target = ($entry.target | path expand --no-symlink)
        let state = if not ($target | path exists) {
            "missing"
        } else if ($target | path type) == "symlink" {
            if (points_to $target $source) { "linked" } else { "wrong-target" }
        } else if (points_to $target $source) {
            "linked (junction — run migrate)"
        } else {
            "conflict"
        }
        { source: $entry.source, target: $entry.target, state: $state }
    }
}

# Remove only symlinks that point to the managed source.
export def unlink [
    --dry-run (-n)  # Print actions without executing
] {
    let ctx = (load_spec)
    for entry in $ctx.active {
        let source = ($ctx.repo | path join $entry.source)
        let target = ($entry.target | path expand --no-symlink)
        if not ($target | path exists) {
            print $"[skip] not found: ($target)"
            continue
        }
        if ($target | path type) == "symlink" {
            if (points_to $target $source) {
                if $dry_run {
                    print $"[dry-run] would unlink: ($target)"
                } else {
                    rm ($target | str trim --right --char '/')
                    print $"[unlinked] ($target)"
                }
            } else {
                print $"[skip] symlink points elsewhere, leaving: ($target)"
            }
        } else {
            print $"[skip] not a symlink, leaving: ($target)"
        }
    }
}

# Copy a real path into the repo, register it in dots.toml, and symlink back.
# Mirrors `chezmoi add`. Usage: add <real-path> [--platforms linux-64,win-64]
export def add [
    real_path: string,
    --platforms (-p): string = ""
    --dry-run (-n)  # Print actions without executing
] {
    let repo = (get_repo_root)
    let spec_file = ($repo | path join "dots.toml")
    let expanded = ($real_path | path expand --no-symlink)
    if not ($expanded | path exists) {
        error make { msg: $"Path does not exist: ($expanded)" }
    }
    let source = (encode_path $real_path)
    let dest = ($repo | path join $source)
    let dest_parent = ($dest | path dirname)
    if $dry_run {
        print $"[dry-run] would copy: ($expanded) -> ($dest)"
    } else {
        if not ($dest_parent | path exists) {
            mkdir $dest_parent
        }
        cp -r $expanded $dest
        print $"[copied] ($expanded) -> ($dest)"
    }
    # Remove original and create symlink; restore from the repo copy on failure.
    if $dry_run {
        print $"[dry-run] would remove: ($expanded)"
        print $"[dry-run] would link: ($dest) -> ($expanded)"
    } else {
        try {
            rm -rf ($expanded | str trim --right --char '/')
            let target_parent = ($expanded | path dirname)
            if not ($target_parent | path exists) {
                mkdir $target_parent
            }
            create_link $dest $expanded
            print $"[linked] ($dest) -> ($expanded)"
        } catch { |err|
            print $"[error] Symlink failed, restoring original: ($err.msg)"
            if not ($expanded | path exists) {
                cp -r $dest $expanded
            }
            rm -rf $dest
            error make { msg: $"Failed to add ($real_path): ($err.msg)" }
        }
    }
    let target_tilde = (to_tilde_path $expanded)
    let platforms_line = if ($platforms | str length) > 0 {
        let plat_list = ($platforms | split row "," | each { |p| $"\"($p | str trim)\"" } | str join ", ")
        $"\nplatforms = [($plat_list)]"
    } else {
        ""
    }
    let entry = $"\n[[links]]\nsource = \"($source)\"\ntarget = \"($target_tilde)\"($platforms_line)\n"
    if $dry_run {
        print $"[dry-run] would register: ($source) -> ($target_tilde)"
    } else {
        let current = if ($spec_file | path exists) {
            open --raw $spec_file
        } else {
            ""
        }
        ($current + $entry) | save --force $spec_file
        print $"[registered] ($source) -> ($target_tilde)"
    }
}

# Register an existing repo source at a target path and create the symlink.
# Use to add a new platform variant for content already in the repo.
# Usage: link <repo-source> <real-path> [--platforms linux-64,win-64]
export def "link" [
    source: string,
    real_path: string,
    --platforms (-p): string = ""
    --dry-run (-n)  # Print actions without executing
] {
    let repo = (get_repo_root)
    let spec_file = ($repo | path join "dots.toml")
    let source_path = ($repo | path join $source)
    if not ($source_path | path exists) {
        error make { msg: $"Source does not exist in repo: ($source_path)" }
    }
    let expanded = ($real_path | path expand --no-symlink)
    let state = (prepare_target $expanded $source_path $dry_run)
    if $state == "linked" {
        print $"[ok] already linked: ($expanded)"
        return
    }
    let parent = ($expanded | path dirname)
    if not $dry_run {
        if not ($parent | path exists) {
            mkdir $parent
        }
    }
    if $dry_run {
        print $"[dry-run] would link: ($source_path) -> ($expanded)"
    } else {
        create_link $source_path $expanded
        print $"[linked] ($source_path) -> ($expanded)"
    }
    let target_tilde = (to_tilde_path $expanded)
    let platforms_line = if ($platforms | str length) > 0 {
        let plat_list = ($platforms | split row "," | each { |p| $"\"($p | str trim)\"" } | str join ", ")
        $"\nplatforms = [($plat_list)]"
    } else {
        ""
    }
    let entry = $"\n[[links]]\nsource = \"($source)\"\ntarget = \"($target_tilde)\"($platforms_line)\n"
    if $dry_run {
        print $"[dry-run] would register: ($source) -> ($target_tilde)"
    } else {
        let current = if ($spec_file | path exists) {
            open --raw $spec_file
        } else {
            ""
        }
        ($current + $entry) | save --force $spec_file
        print $"[registered] ($source) -> ($target_tilde)"
    }
}

# Unmanage a target: unlink the symlink and move the repo source back to the
# system location. Nothing is deleted. Usage: remove <target-path>
export def remove [
    target_path: string  # System target path (e.g. ~/.config/nvim) to unmanage
    --dry-run (-n)       # Print actions without executing
] {
    let ctx = (load_spec)
    let removed = ($ctx.links | where { |e| (paths_equal $e.target $target_path) })
    if ($removed | length) == 0 {
        print $"[not found] no entry with target: ($target_path)"
        return
    }
    for entry in $removed {
        let source_path = ($ctx.repo | path join $entry.source)
        let target = ($entry.target | path expand --no-symlink)
        if not ($source_path | path exists) {
            print $"[skip] repo source missing, nothing to restore: ($source_path)"
            continue
        }
        if ($target | path exists) {
            if ($target | path type) == "symlink" {
                if (points_to $target $source_path) {
                    if $dry_run {
                        print $"[dry-run] would unlink: ($target)"
                        print $"[dry-run] would move: ($source_path) -> ($target)"
                    } else {
                        rm ($target | str trim --right --char '/')
                        print $"[unlinked] ($target)"
                        let target_parent = ($target | path dirname)
                        if not ($target_parent | path exists) {
                            mkdir $target_parent
                        }
                        mv $source_path $target
                        print $"[restored] ($source_path) -> ($target)"
                    }
                } else {
                    print $"[skip] symlink points elsewhere, leaving: ($target)"
                }
            } else {
                print $"[skip] target exists and is not a managed symlink: ($target)"
            }
        } else {
            # Target gone: just move the source back.
            if $dry_run {
                print $"[dry-run] would move: ($source_path) -> ($target)"
            } else {
                let target_parent = ($target | path dirname)
                if not ($target_parent | path exists) {
                    mkdir $target_parent
                }
                mv $source_path $target
                print $"[restored] ($source_path) -> ($target)"
            }
        }
    }
    rewrite_spec_without $ctx.spec_file ($removed | get source) $dry_run "removed" $target_path
}

# Unmanage a target AND delete both the symlink and the repo source. This
# destroys the files. Use `remove` to keep them. Usage: purge <target-path>
export def purge [
    target_path: string  # System target path (e.g. ~/.config/nvim) to purge entirely
    --dry-run (-n)       # Print actions without executing
] {
    let ctx = (load_spec)
    let removed = ($ctx.links | where { |e| (paths_equal $e.target $target_path) })
    if ($removed | length) == 0 {
        print $"[not found] no entry with target: ($target_path)"
        return
    }
    for entry in $removed {
        let source_path = ($ctx.repo | path join $entry.source)
        let target = ($entry.target | path expand --no-symlink)
        if ($target | path exists) {
            if ($target | path type) == "symlink" {
                if (points_to $target $source_path) {
                    if $dry_run {
                        print $"[dry-run] would unlink: ($target)"
                    } else {
                        rm ($target | str trim --right --char '/')
                        print $"[unlinked] ($target)"
                    }
                } else {
                    print $"[skip] symlink points elsewhere, leaving: ($target)"
                }
            } else {
                print $"[skip] target exists and is not a managed symlink: ($target)"
            }
        }
        if ($source_path | path exists) {
            if $dry_run {
                print $"[dry-run] would delete repo source: ($source_path)"
            } else {
                rm -rf $source_path
                print $"[deleted] ($source_path)"
            }
        } else {
            print $"[skip] repo source already gone: ($source_path)"
        }
    }
    rewrite_spec_without $ctx.spec_file ($removed | get source) $dry_run "purged" $target_path
}

# Windows one-time cleanup: convert managed legacy junctions (from older runs
# that used mklink /J) into real symlinks. Safe — a junction is a reparse point
# that holds no data of its own, so removing it never touches the target.
export def migrate [
    --dry-run (-n)  # Print actions without executing
] {
    if $nu.os-info.name != "windows" {
        print "migrate is only needed on Windows (legacy junction -> symlink cleanup)"
        return
    }
    let ctx = (load_spec)
    for entry in $ctx.active {
        let source = ($ctx.repo | path join $entry.source)
        let target = ($entry.target | path expand --no-symlink)
        if not ($target | path exists) {
            continue
        }
        if ($target | path type) == "symlink" {
            print $"[ok] already a symlink: ($target)"
            continue
        }
        if (is_junction $target) {
            if not ($source | path exists) {
                print $"[skip] repo source missing, leaving junction: ($target)"
                continue
            }
            if $dry_run {
                print $"[dry-run] would replace junction with symlink: ($target)"
            } else {
                let win = ($target | str replace -a '/' '\')
                let r = (do { ^cmd /c $"rmdir \"($win)\"" } | complete)
                if $r.exit_code != 0 {
                    print $"[error] failed to remove junction ($target): ($r.stderr)"
                    continue
                }
                create_link $source $target
                print $"[migrated] ($target): junction -> symlink"
            }
        } else {
            print $"[skip] not a managed symlink or junction: ($target)"
        }
    }
}

