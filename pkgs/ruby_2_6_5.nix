{ stdenv, fetchurl, autoconf, automake, bison, pkg-config
, openssl, zlib, libyaml, libffi, gdbm, readline, lib }:

stdenv.mkDerivation rec {
  pname = "ruby";
  version = "2.6.5";

  src = fetchurl {
    url = "https://cache.ruby-lang.org/pub/ruby/2.6/ruby-${version}.tar.gz";
    sha256 = "ZpdrcW7MH9NPm3w8Kwe703YxgVN3ouPoWlsZTP3L7X0=";
  };

  patches = [
    ./patches/ruby-2.6.5-darwin-libffi.patch
  ];

  nativeBuildInputs = [
    autoconf automake bison pkg-config
  ];

  buildInputs = [
    openssl.dev openssl.out
    zlib libyaml libffi gdbm readline
  ];

  configurePhase = ''
    export LDFLAGS="-L${openssl.out}/lib"
    export CPPFLAGS="-I${openssl.dev}/include"

    ./configure \
      --prefix=$out \
      --with-openssl-dir=${openssl.dev} \
      --enable-shared
  '';

  meta = {
    description = "Ruby ${version}";
    homepage = "https://www.ruby-lang.org/";
    license = lib.licenses.ruby;
    platforms = lib.platforms.unix;
  };
}
