test:
  nix run .#nvim flake.nix

t ext:
  nix run .#nvim "./test_files/test.{{ext}}"

shell:
  nix shell .#nvim

rust-test:
  nix run .#nvim "./test_files/rust_demo/src/main.rs"
