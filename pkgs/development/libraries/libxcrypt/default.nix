{ lib, stdenv, stdenvNoCC, buildPackages, fetchurl, perl, nixosTests, headersOnly ? false }:

(if headersOnly then stdenvNoCC else stdenv).mkDerivation rec {
  pname = "libxcrypt" + lib.optionalString headersOnly "-headers";
  version = "4.4.33";

  src = fetchurl {
    url = "https://github.com/besser82/libxcrypt/releases/download/v${version}/libxcrypt-${version}.tar.xz";
    hash = "sha256-6HrPnGUsVzpHE9VYIVn5jzBdVu1fdUzmT1fUGU1rOm8=";
  };

  outputs = [
    "out"
  ] ++ lib.optionals (!headersOnly) [
    "man"
  ];

  ${if (stdenv.hostPlatform != stdenv.buildPlatform) && !headersOnly then "preConfigure" else null}  = ''
    export CC="${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
    export CC_FOR_BUILD="${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc"
  '';

  configureFlags = [
    "--enable-hashes=all"
    "--enable-obsolete-api=glibc"
    "--disable-failure-tokens"
  ] ++ lib.optionals (stdenv.hostPlatform.isMusl || stdenv.hostPlatform.libc == "bionic" || stdenv.hostPlatform != stdenv.buildPlatform) [
    "--disable-werror"
  ];

  nativeBuildInputs = [
    perl
  ];

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];

  ${if (headersOnly) then "CC" else null} = "${buildPackages.stdenv.cc}/bin/${buildPackages.stdenv.cc.targetPrefix}cc";

  enableParallelBuilding = true;

  installTargets = lib.optional headersOnly "install-nodist_includeHEADERS";

  doCheck = !headersOnly;

  passthru.tests = {
    inherit (nixosTests) login shadow;
  };

  meta = with lib; {
    description = "Extended crypt library for descrypt, md5crypt, bcrypt, and others";
    homepage = "https://github.com/besser82/libxcrypt/";
    platforms = platforms.all;
    maintainers = with maintainers; [ dottedmag hexa ];
    license = licenses.lgpl21Plus;
  };
}
