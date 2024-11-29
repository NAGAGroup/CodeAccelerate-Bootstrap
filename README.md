# CodeAccelerate++ Bootstrap: Cross-Platform Dotfiles for C++ Developers

**CodeAccelerate++ Bootstrap** is a collection of dotfiles and installation
scripts managed by [chezmoi](https://www.chezmoi.io/) and powered by
[pixi](https://www.pixi.sh/). It is designed primarily for C++ developers
working from the command line. However, even if you’re not a C++ developer, you
may find CodeAccelerate++ Bootstrap useful as a foundation for setting up your
own terminal-centric workstation. Check out the features section to see if
CodeAccelerate++ Bootstrap might be right for you!

CodeAccelerate++ Bootstrap currently targets Windows and Linux, but it should be
easy to adapt for macOS by modifying the Linux-specific sections.

## Who is This For?

### Developers

For developers who work primarily from the terminal, whether by choice or due to
a role requiring remote workstations. I started as the latter, but now I can’t
imagine working any other way after putting so much effort into these dotfiles.

### Those Exploring Terminal-Centric Development

If you’re interested in a terminal-centric workflow, CodeAccelerate++ Bootstrap
is a great way to dive in. A terminal-first setup offers unmatched flexibility,
especially with a tool like Neovim, which shines not only in remote workflows
but also in its low memory footprint, speed, and powerful editing features
inspired by Vim.

Neovim’s editing style has a learning curve, but once you get comfortable with
it, it transforms how you think about code. Vim’s modal editing allows you to
navigate, edit, and manipulate text at lightning speed with minimal reliance on
the mouse. Many developers find themselves wanting Neovim everywhere once
they’ve experienced its efficiency and flow.

In my own journey, I initially relied on CLion and appreciated its features, but
once I shifted to Neovim for a terminal-centric experience, I was sold. For
remote development, Neovim’s thin client nature is a game-changer: it connects
seamlessly over SSH, allowing you to work directly on remote machines without
sync delays or bloated GUIs. Even on local setups, Neovim provides an
environment that’s not only responsive but highly customizable, making it a
flexible “IDE” replacement.

Whether you're testing the waters of terminal-based development or looking for a
robust setup for Neovim on Windows and Linux, these dotfiles aim to make it all
_just work_.

### Neovim Users on Windows

Getting Neovim to work seamlessly on Windows can be a hassle. With these
dotfiles, your Linux Neovim setup will also _just work_ on Windows!

## Features

- **Rootless, cross-platform package management** via
  [pixi](https://www.pixi.sh/)
- **Uniform shell experience** using [Nushell](https://www.nushell.sh/)
- **GCC toolchains** for both Windows and Linux
- **Zellij multiplexer** (Linux-only for now)
- Latest versions of essential developer tools (e.g., CMake, Python, Git, Ninja)
- **Fully-featured Neovim “IDE” for C++ development** based on
  [LazyVim](https://www.lazyvim.org/):
  - LSP configurations for C++, CMake, Lua, Bash, and more
  - Support for locally hosted AI autocomplete and chat via Copilot and
    CodeCompanion
  - If you don't have Copilot, not to worry! AI features can be enabled by
    locally hosting AI models via TabbyML. More docs on this coming soon!
  - Visual debugging for C++
  - LaTeX/Markdown support
  - Code linting and more!

## Note on WIP

While CodeAccelerate++ Bootstrap is “ready-to-go,” it’s still a
work-in-progress. I’m currently transitioning everything to a unified _Nushell_
environment, and there may still be configurations, such as `kitty.conf`, that
rely on _fish_. Additionally, as the configs settle, there may be small bugs,
broken components, or undocumented features. I’m finalizing some aspects and
will document them over time.

See the `home` directory in the repo for all files that will be installed;
modify as needed.

## Prerequisites

### OS-Agnostic

Just [pixi](https://www.pixi.sh/)!

```bash
curl -fsSL https://pixi.sh/install.sh | bash
source ~/.bashrc
```

### Windows-Only

[Scoop](https://scoop.sh/) fills in the gaps for tools not installable via
_pixi_. I'd also recommend installing the VS 2022 C++ Build Tools, though it
isn’t required, as the GCC toolchain will compile all Neovim plugins.

## Installation

```bash
mkdir -p ~/.local/share
git clone https://github.com/NAGAGroup/CodeAccelerate-Bootstrap.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
pixi run install
source ~/.bashrc
```

## Enabling the Development Environment

Because `pixi` exposes executables in a way that can break some packages, only
`nu` is exposed. In order to access all the installed tools, launch `nu` as it
will add all the tools to the path.

```bash
nu
```

## First Neovim Launch

On the first launch, Neovim will install all specified plugins, which may
involve substantial compilation. Ensure you’re not within a project-specific
_pixi_ environment to avoid conflicts, as Neovim will use the environment's
compiler toolchain for plugins, potentially causing issues if the environment
changes.
