{ stdenvNoCC, fetchFromGitHub, lib }:

stdenvNoCC.mkDerivation rec {
  pname = "terminal-notifier-xcode";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "julienXX";
    repo = "terminal-notifier";
    rev = version;
    hash = "sha256-Hd9cI3R2nQK2deBb5CBYz4DTHAEcO4vzqtA5qZwa1Ao=";
  };

  dontConfigure = true;
  preferLocalBuild = true;
  allowSubstitutes = false;

  # Allow the build to reach the local Xcode toolchain.
  __allowedImpureHostDeps = [
    "/Applications/Xcode.app"
    "/Library/Developer"
  ];

  postPatch = ''
    substituteInPlace "Terminal Notifier/AppDelegate.m" \
      --replace "#import <objc/runtime.h>" "#import <objc/runtime.h>
#import <dispatch/dispatch.h>"
    substituteInPlace "Terminal Notifier/AppDelegate.m" \
      --replace "[center scheduleNotification:userNotification];" "[center scheduleNotification:userNotification];

  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    exit(0);
  });"
  '';

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    /usr/bin/xcodebuild \
      -project "Terminal Notifier.xcodeproj" \
      -scheme "Terminal Notifier" \
      -configuration Release \
      -arch arm64 \
      -derivedDataPath "$TMPDIR/DerivedData" \
      CODE_SIGN_IDENTITY= \
      build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    buildProducts="$TMPDIR/DerivedData/Build/Products/Release"
    mkdir -p $out/Applications
    cp -R "$buildProducts/terminal-notifier.app" "$out/Applications/terminal-notifier.app"
    mkdir -p $out/bin
    cat > $out/bin/terminal-notifier <<EOF
#!/usr/bin/env bash
exec "$out/Applications/terminal-notifier.app/Contents/MacOS/terminal-notifier" "\$@"
EOF
    chmod +x $out/bin/terminal-notifier
    runHook postInstall
  '';

  meta = {
    description = "Command line tool to send macOS notifications (arm64 build via local Xcode)";
    homepage = "https://github.com/julienXX/terminal-notifier";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
  };
}
