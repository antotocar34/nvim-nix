Have you ever wanted to have a completely portable neovim config that will just work on any machine you're on---as long as it has nix?
By portable, I mean even the language server binaries , treesitter grammars and any external binaries (such as zathura for `vimtex`) are automatically
installed and are kept separate from other system packages.

## How to run / install

To run:
```
nix run github:antotocar34/nvim-nix#neovim
```

To install:
```
nix profile install github:antotocar34/nvim-nix#neovim github:antotocar34/nvim-nix#neovimMinimal
```

## How does it work?
This is based off of `jordanisaacs` wonderful [neovim-flake](https://github.com/jordanisaacs/neovim-flake).

The basic idea is this: 
just as the nixos module system can manage a system configuration so can
it manage a neovim configuration!

### Advantages:
  - Reproducibility: If it works at one point in time, it will work in the future!
  - Portability: Any (linux at least) machine with nix installed will run this.
  - Ease of use: Once a module is defined (the hard work), installing it is as easy as setting `foo.enable = true`.
                 This means one can share complicated configurations just by sharing the right module.
