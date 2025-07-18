{
  stdenv,
  lib,
  fetchzip,
  cmake,
  gitUpdater,
}:

stdenv.mkDerivation rec {
  pname = "openfec";
  version = "1.4.2.12";

  src = fetchzip {
    url = "https://github.com/roc-streaming/openfec/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-KOP3LqCZHdEgm+XhzBdNxnJipGC4gpvA57T7mIeSyaE=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
  ];

  cmakeFlags = [
    "-DDEBUG:STRING=OFF"
    (lib.cmakeBool "BUILD_STATIC_LIBS" stdenv.hostPlatform.isStatic)
  ];

  installPhase =
    let
      so = stdenv.hostPlatform.extensions.library;
    in
    ''
      # This is pretty horrible but sadly there is not installation procedure
      # provided.
      mkdir -p $dev/include
      cp -R ../src/* $dev/include
      find $dev/include -type f -a ! -iname '*.h' -delete

      install -D -m755 -t $out/lib ../bin/Release/libopenfec${so}
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      install_name_tool -id $out/lib/libopenfec${so} $out/lib/libopenfec${so}
    ''
    + ''
      ln -s libopenfec${so} $out/lib/libopenfec${so}.1
    '';

  passthru.updateScript = gitUpdater {
    url = "https://github.com/roc-streaming/openfec.git";
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "Application-level Forward Erasure Correction codes";
    homepage = "https://github.com/roc-streaming/openfec";
    license = licenses.cecill-c;
    maintainers = with maintainers; [ bgamari ];
    platforms = platforms.unix;
  };
}
