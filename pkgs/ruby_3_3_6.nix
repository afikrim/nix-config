{ stdenv, fetchurl, autoconf, automake, bison, pkg-config
, openssl, zlib, libyaml, libffi, gdbm, readline, lib }:

stdenv.mkDerivation rec {
  pname = "ruby";
  version = "3.3.6";

  src = fetchurl {
    url = "https://cache.ruby-lang.org/pub/ruby/3.3/ruby-${version}.tar.gz";
    sha256 = "jcSP/68nD4bxAZBT8o5R5NpMzjKjZ2CgYDqa7mfX/Y0=";
  };

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
    export HOME=$TMPDIR

    ./configure \
      --prefix=$out \
      --with-openssl-dir=${openssl.dev} \
      --enable-shared \
      --disable-install-doc
  '';

  buildPhase = ''
    export HOME=$TMPDIR
    make -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    export HOME=$TMPDIR
    make install
  '';

  meta = {
    description = "Ruby ${version}";
    homepage = "https://www.ruby-lang.org/";
    license = lib.licenses.ruby;
    platforms = lib.platforms.unix;
  };
}
