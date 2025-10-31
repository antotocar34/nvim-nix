{ 
  pkgs ? (
    let
      lock = builtins.fromJSON (builtins.readFile ../flake.lock);
      rev = lock.nodes.nixpkgs.locked.rev;
      nixpkgs = builtins.fetchTarball {
        url="https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
        };
    in
    import nixpkgs {}
  )
}:
let
allPackages = {
  bqls = pkgs.callPackage ./bqls.nix {};
  bqls-with-pr = pkgs.callPackage ./bqls-with-pr.nix {};
};
in
pkgs.symlinkJoin {
          name = "derivations";
          paths = builtins.attrValues allPackages;
        }
