pkgs:
let
allPackages = {
  bqls = pkgs.callPackage ./bqls.nix {};
};
in
pkgs.symlinkJoin {
          name = "derivations";
          paths = builtins.attrValues allPackages;
        }
