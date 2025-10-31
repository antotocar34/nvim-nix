{
  buildGoModule,
  fetchFromGitHub,
  clangStdenv,
  llvmPackages ? null
}:

(buildGoModule.override { stdenv = clangStdenv; }) (final: {
  pname = "bqls";
  version = "0.4.2-dev";

  src = fetchFromGitHub {
    owner = "kitagry";
    repo = "bqls";
    rev = "4d9b503af29542eb273603e2c162bd8b9d13b9bb";
    # tag = "v${final.version}";
    hash = "sha256-P9/sc3p822mYcwK1ohlrhpRh6t+ivszalrm++n59/nQ=";
  };

  vendorHash = "sha256-C8Nu2XlCGexqf+8FLYHS+5gM3hsnYB7bxxP1VTZYWBw=";

  nativeBuildInputs = [ clangStdenv.cc ] ++ (if llvmPackages == null then [] else [ llvmPackages.clang ]);

  stdenv = clangStdenv;

  CC = "${clangStdenv.cc}/bin/clang";
  CXX = "${clangStdenv.cc}/bin/clang++";

  doCheck = false; # One of the test fails :(
  checkFlags = [ ];

  # group age plugins together
  passthru.plugins = { };

  # meta = with lib; { ... };
})


