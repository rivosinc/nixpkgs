{ lib, stdenv, stdenvNoCC, buildPackages, fetchurl, perl, nixosTests, headersOnly ? false }:

(if headersOnly then stdenvNoCC else stdenv).mkDerivation rec {
  pname = "libxcrypt" + lib.optionalString headersOnly "-headers";
  version = "4.4.30";

  src = fetchurl {
    url = "https://github.com/besser82/libxcrypt/releases/download/v${version}/libxcrypt-${version}.tar.xz";
    sha256 = "sha256-s2Z/C6hdqtavJGukCQ++UxY62TyLaioSV9IqeLt87ro=";
  };

  outputs = [
    "out"
  ] ++ lib.optionals (!headersOnly) [
    "man"
  ];

  configureFlags = [
    "--enable-hashes=all"
    "--enable-obsolete-api=glibc"
    "--disable-failure-tokens"
  ] ++ lib.optionals (stdenv.hostPlatform.isMusl || stdenv.hostPlatform.libc == "bionic") [
    "--disable-werror"
  ];

  nativeBuildInputs = [
    perl
  ];

  depsBuildBuild = [
    buildPackages.stdenv.cc
  ];

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
