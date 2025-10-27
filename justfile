test:
  nix run . flake.nix

t ext:
  nix profile upgrade
  nvim "./test_files/test.{{ext}}"

shell:
  nix shell .#nvim

rust-test:
  nix run .#nvim "./test_files/rust_demo/src/main.rs"

reinstall:
  nix profile remove nvim-nix
  nix profile add .
