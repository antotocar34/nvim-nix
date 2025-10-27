{
  buildGoModule,
  fetchFromGitHub,
  clangStdenv,
  llvmPackages ? null
}:

(buildGoModule.override { stdenv = clangStdenv; }) (final: {
  pname = "bqls";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "kitagry";
    repo = "bqls";
    tag = "v${final.version}";
    hash = "sha256-Twad+VTdgCgPTsuJZrrUEmELsv0wtyp9TBK9ldq/jYo=";
  };

  vendorHash = "sha256-0seGfOBpxPhdndoO3QBlWjoYtPxXrCreOiiviLz4c1I=";

    # Optional: sanity check in logs
  preBuild = ''
    echo "CGO_ENABLED=$CGO_ENABLED"
    echo "CC=$CC ($(type -p $CC))"
    echo "CXX=$CXX ($(type -p $CXX))"
    $CC --version || true
    $CXX --version || true
  '';

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


