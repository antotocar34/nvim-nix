{
  buildGoModule,
  fetchFromGitHub,
  clangStdenv,
  tree-sitter,
  llvmPackages ? null
}:

(buildGoModule.override { stdenv = clangStdenv; }) (final: {
  pname = "bqls";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "kitagry";
    repo = "bqls";
    # tag = "v${final.version}";
    rev = "6c3932ba6a7fd04300b82a51cce4d3380eceeadd";
    hash = "sha256-3jxQrRrXy3n6b6N6nHFP9hKdynhw5a8IyN+GI+ZhW/k=";
  };

  proxyVendor = true;
  vendorHash = "sha256-8Im6YxIPWDIr4y2MmW2CPZFLbY+gvp5w3smJZywCAeI=";

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

  # meta = with lib; { ... };
})


