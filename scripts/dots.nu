# Platform detection helper
def get_platform [] {
    if $nu.os-info.name == "windows" { "win-64" } else { "linux-64" }
}

# Source path resolution helper
const dots_nu = path self
def get_repo_root [] {
     $dots_nu | path dirname | path dirname
}

# Link creation helper - creates symlinks (with Windows junction fallback for dirs)
def create_link [source: string, target: string] {
    if $nu.os-info.name == "windows" {
        let is_dir = ($source | path type) == "dir"
        if $is_dir {
            let result = (do { ^cmd /c $"mklink /D ($target) ($source)" } | complete)
            if $result.exit_code != 0 {
                print $"[notice] Using junction for ($target) - enable Developer Mode for true symlinks"
                let junction = (do { ^cmd /c $"mklink /J ($target) ($source)" } | complete)
                if $junction.exit_code != 0 {
                    error make { msg: $"Failed to create junction for ($target): ($junction.stderr)" }
                }
            }
        } else {
            let result = (do { ^cmd /c $"mklink ($target) ($source)" } | complete)
            if $result.exit_code != 0 {
                error make { msg: $"Failed to create symlink for ($target): ($result.stderr)" }
            }
        }
    } else {
        let result = (do { ln -sf $source $target } | complete)
        if $result.exit_code != 0 {
            error make { msg: $"Failed to create symlink for ($target): ($result.stderr)" }
        }
    }
}

# Read the target of a symlink, cross-platform
def read_link_target [path: string] {
    if $nu.os-info.name == "windows" {
        # PowerShell Get-Item can read symlink/junction targets
        let result = (do { ^powershell -NoProfile -Command $"(Get-Item '($path)').Target" } | complete)
        if $result.exit_code == 0 {
            $result.stdout | str trim
        } else {
            ""
        }
    } else {
        let result = (do { ^readlink $path } | complete)
        if $result.exit_code == 0 {
            $result.stdout | str trim
        } else {
            ""
        }
    }
}

# Filter links for current platform
def filter_links [links: list<record>, platform: string] {
    $links | where {
        |entry|
        if "platforms" in $entry {
            $platform in $entry.platforms
        } else {
            true
        }
    }
}

# Encode a real absolute path to a repo-relative source path.
# Leading dot segments are prefixed with dot_ so they are not hidden in the repo.
# Only the leading dot of each path segment is encoded.
# e.g. ~/.config/nushell  -> dot_config/nushell
#      ~/.tmux.conf        -> dot_tmux.conf
#      ~/bin/tool          -> bin/tool
def encode_path [real_path: string] {
    let expanded = ($real_path | path expand)
    let home = ($nu.home-dir)
    # Strip the home prefix to get the relative portion
    let rel = if ($expanded | str starts-with $home) {
        $expanded | str replace $"($home)/" ""
    } else {
        error make { msg: $"Path ($real_path) is not under home directory ($home)" }
    }
    # Encode each segment: if segment starts with '.', replace leading '.' with 'dot_'
    let segments = ($rel | path split)
    let encoded = ($segments | each { |seg|
        if ($seg | str starts-with ".") {
            "dot_" + ($seg | str replace --regex '^\.+' "")
        } else {
            $seg
        }
    })
    $encoded | path join
}

# Convert an expanded absolute path under $HOME to a ~/... tilde path
def to_tilde_path [expanded: string] {
    "~/" + ($expanded | path relative-to $nu.home-dir)
}

# Load dots.toml and return {repo, platform, spec_file, links, active}
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

# Sync command - creates symlinks based on dots.toml.
# Use --dry-run (-n) to preview actions without making changes.
export def sync [
    --dry-run (-n)  # Print actions without executing
] {
    let ctx = (load_spec)

    for entry in $ctx.active {
        let source = ($ctx.repo | path join $entry.source)
        let target = ($entry.target | str replace "~" $nu.home-dir)

        if not ($source | path exists) {
            print $"[skip] source does not exist: ($source)"
            continue
        }

        # Check if already correctly linked
        if ($target | path exists) {
            let link_type = ($target | path type)
            if $link_type == "symlink" {
                let current = (read_link_target $target)
                if $current == $source {
                    print $"[ok] already linked: ($target)"
                    continue
                }
            }
            # Exists but wrong - back it up
            let bak = ($target + ".bak")
            if $dry_run {
                print $"[dry-run] would backup: ($target) -> ($bak)"
            } else {
                print $"[backup] ($target) -> ($bak)"
                mv --force $target $bak
            }
        }

        # Create parent dirs if needed
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

# Status command - shows current symlink status.
# Accepts --dry-run (-n) for CLI consistency; status is read-only and behaviour is unchanged.
export def status [
    --dry-run (-n)  # Accepted for CLI consistency; status is always read-only
] {
    if $dry_run {
        print "[dry-run] status is read-only, showing current state:"
    }
    let ctx = (load_spec)

    let rows = ($ctx.active | each { |entry|
        let source = ($ctx.repo | path join $entry.source)
        let target = ($entry.target | str replace "~" $nu.home-dir)

        let state = if not ($target | path exists) {
            "missing"
        } else {
            let link_type = ($target | path type)
            if $link_type == "symlink" {
                let current = (read_link_target $target)
                if $current == $source {
                    "linked"
                } else {
                    "wrong-target"
                }
            } else {
                "conflict"
            }
        }

        { source: $entry.source, target: $entry.target, state: $state }
    })

    $rows
}

# Unlink command - removes only symlinks that point to the managed source.
# Use --dry-run (-n) to preview which symlinks would be removed.
export def unlink [
    --dry-run (-n)  # Print actions without executing
] {
    let ctx = (load_spec)

    for entry in $ctx.active {
        let source = ($ctx.repo | path join $entry.source)
        let target = ($entry.target | str replace "~" $nu.home-dir)

        if not ($target | path exists) {
            print $"[skip] not found: ($target)"
            continue
        }

        let link_type = ($target | path type)
        if $link_type == "symlink" {
            let current = (read_link_target $target)
            if $current == $source {
                if $dry_run {
                    print $"[dry-run] would unlink: ($target)"
                } else {
                    rm $target
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

# Add command - copies a real path into the repo, registers it in dots.toml, and symlinks back.
# Mirrors `chezmoi add` behaviour.
# Use --dry-run (-n) to preview all steps without making any changes.
# Usage: add <real-path> [--platforms linux-64,win-64]
export def add [
    real_path: string,
    --platforms (-p): string = ""
    --dry-run (-n)  # Print actions without executing
] {
    let repo = (get_repo_root)
    let spec_file = ($repo | path join "dots.toml")
    let expanded = ($real_path | path expand)

    if not ($expanded | path exists) {
        error make { msg: $"Path does not exist: ($expanded)" }
    }

    let source = (encode_path $real_path)
    let dest = ($repo | path join $source)

    # Copy into repo
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

    # Remove original and create symlink - restore on failure
    if $dry_run {
        print $"[dry-run] would remove: ($expanded)"
        print $"[dry-run] would link: ($dest) -> ($expanded)"
    } else {
        try {
            rm -rf $expanded

            # Create parent dirs for target if needed
            let target_parent = ($expanded | path dirname)
            if not ($target_parent | path exists) {
                mkdir $target_parent
            }

            create_link $dest $expanded
            print $"[linked] ($dest) -> ($expanded)"
        } catch { |err|
            # Restore the original from the repo copy
            print $"[error] Symlink failed, restoring original: ($err.msg)"
            if not ($expanded | path exists) {
                cp -r $dest $expanded
            }
            # Clean up the repo copy since we failed
            rm -rf $dest
            error make { msg: $"Failed to add ($real_path): ($err.msg)" }
        }
    }

    # Append dots.toml entry
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

# Link command - registers an existing repo source with a target path in dots.toml and creates the symlink.
# Use this to add a new platform variant for content already in the repo.
# Use --dry-run (-n) to preview all steps without making any changes.
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

    let expanded = ($real_path | path expand)

    # Backup existing target if present and not already the correct symlink
    if ($expanded | path exists) {
        let link_type = ($expanded | path type)
        if $link_type == "symlink" {
            let current = (read_link_target $expanded)
            if $current == $source_path {
                print $"[ok] already linked: ($expanded)"
                return
            }
        }
        let bak = ($expanded + ".bak")
        if $dry_run {
            print $"[dry-run] would backup: ($expanded) -> ($bak)"
        } else {
            print $"[backup] ($expanded) -> ($bak)"
            mv --force $expanded $bak
        }
    }

    # Create parent dirs if needed
    let parent = ($expanded | path dirname)
    if not $dry_run {
        if not ($parent | path exists) {
            mkdir $parent
        }
    }

    # Create symlink
    if $dry_run {
        print $"[dry-run] would link: ($source_path) -> ($expanded)"
    } else {
        create_link $source_path $expanded
        print $"[linked] ($source_path) -> ($expanded)"
    }

    # Append dots.toml entry
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

# Remove command - removes an entry from dots.toml and unlinks.
# Uses raw text manipulation to preserve comments and formatting.
# Use --dry-run (-n) to preview changes without modifying dots.toml or removing symlinks.
export def remove [
    source: string
    --dry-run (-n)  # Print actions without executing
] {
    let ctx = (load_spec)

    let removed = ($ctx.links | where { |e| $e.source == $source })

    if ($removed | length) == 0 {
        print $"[not found] no entry with source: ($source)"
        return
    }

    # Remove matching [[links]] blocks from the raw TOML text.
    # Strategy: split into blocks, check each block for the matching source, keep non-matching blocks.
    let raw = (open --raw $ctx.spec_file)
    let lines = ($raw | lines)

    # First, collect the preamble (lines before any [[links]]) and each [[links]] block
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
    # Flush last block
    if $in_block {
        $blocks = ($blocks | append [($current_block | str join "\n")])
    }

    # Filter out blocks whose source matches
    let kept = ($blocks | where { |block|
        not ($block | str contains $"source = \"($source)\"")
    })

    # Reassemble: preamble + kept blocks
    let preamble_text = ($preamble | str join "\n")
    let blocks_text = ($kept | str join "\n\n")
    let new_content = if ($kept | length) > 0 {
        $preamble_text + "\n\n" + $blocks_text + "\n"
    } else {
        $preamble_text + "\n"
    }
    if $dry_run {
        print $"[dry-run] would update dots.toml: remove entry for ($source)"
    } else {
        $new_content | save --force $ctx.spec_file
    }

    # Unlink any managed symlinks for removed entries
    for entry in $removed {
        let source_path = ($ctx.repo | path join $entry.source)
        let target = ($entry.target | str replace "~" $nu.home-dir)
        if ($target | path exists) {
            let link_type = ($target | path type)
            if $link_type == "symlink" {
                let current = (read_link_target $target)
                if $current == $source_path {
                    if $dry_run {
                        print $"[dry-run] would unlink: ($target)"
                    } else {
                        rm $target
                        print $"[unlinked] ($target)"
                    }
                } else {
                    print $"[skip] symlink points elsewhere, leaving: ($target)"
                }
            }
        }
    }

    print $"[removed] ($source)"
}
