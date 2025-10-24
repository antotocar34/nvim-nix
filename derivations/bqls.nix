{
  buildGoModule,
  fetchFromGitHub,
  clangStdenv
}:

buildGoModule (final: {
  pname = "bqls";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "kitagry";
    repo = "bqls";
    tag = "v${final.version}";
    hash = "sha256-Twad+VTdgCgPTsuJZrrUEmELsv0wtyp9TBK9ldq/jYo=";
  };

  vendorHash = "sha256-0seGfOBpxPhdndoO3QBlWjoYtPxXrCreOiiviLz4c1I=";

  stdenv = clangStdenv;

  env.CGO_ENABLED = 1;

  # One of the test fails :(
  doCheck = false;

  # plugin test is flaky, see https://github.com/FiloSottile/age/issues/517
  checkFlags = [
  ];

  # group age plugins together
  passthru.plugins = { };

  # meta = with lib; { ... };
})


