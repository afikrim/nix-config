{ pkgs, ruby_3_3_6 }:

let
  bundler = pkgs.stdenv.mkDerivation {
    pname = "bundler";
    version = "2.5.22";

    src = pkgs.fetchurl {
      url = "https://rubygems.org/downloads/bundler-2.5.22.gem";
      sha256 = "dj8w1ZjuWHQu6ikoWHVDXqciIY1N8UneNbzjfALOlo4=";
    };

    buildInputs = [ ruby_3_3_6 ];

    unpackPhase = "true"; # .gem files cannot be unpacked normally

    installPhase = ''
      mkdir -p $out/bin
      export GEM_HOME="$out/lib/ruby/gems/3.3.0"
      export GEM_PATH="$GEM_HOME"

      ${ruby_3_3_6}/bin/gem install $src --no-document --install-dir "$GEM_HOME"

      # symlink specific versioned binaries
      ln -s $GEM_HOME/bin/bundle  $out/bin/bundle3.3.6
      ln -s $GEM_HOME/bin/bundler $out/bin/bundler3.3.6
      ln -s ${ruby_3_3_6}/bin/gem  $out/bin/gem3.3.6
    '';
  };
in

pkgs.buildEnv {
  name = "ruby3.3.6-env";

  paths = [
    ruby_3_3_6
    bundler
  ];

  pathsToLink = [ "/bin" ];
}

