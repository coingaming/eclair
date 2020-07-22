# This file has been generated by mavenix-2.3.3. Configure the build here!
let
  mavenix-src = fetchTarball { url = "https://github.com/nix-community/mavenix/tarball/v2.3.3"; sha256 = "1l653ac3ka4apm7s4qrbm4kx7ij7n2zk3b67p9l0nki8vxxi8jv7"; };
in {
  # pkgs is pinned to 19.09 in mavenix-src,
  # replace/invoke with <nixpkgs> or /path/to/your/nixpkgs_checkout
  pkgs ? (import mavenix-src {}).pkgs,
  mavenix ? import mavenix-src { inherit pkgs; },
  src ? ./.,
  doCheck ? false,
}:
with pkgs;
mavenix.buildMaven {
  inherit src;
  doCheck = false;
  debug = true;
  infoFile = ./mavenix.lock;

  # Add build dependencies
  #
  buildInputs = [ git unzip makeWrapper wget jdk11 maven openssh cacert ];

  # Set build environment variables
  #
  TERM="xterm-256color";
  MAVEN_OPTS="-Dfile.encoding=UTF-8 -Dmaven.test.skip=true";
  GIT_SSL_CAINFO="${cacert}/etc/ssl/certs/ca-bundle.crt";

  # Attributes are passed to the underlying `stdenv.mkDerivation`, so build
  #   hooks can be set here also.
  #
  preBuild = ''
    rm -rf ./.git
  '';
  installPhase = ''
    export THIS_DIST="eclair-node-0.4.1-SNAPSHOT-\''${git.commit.id.abbrev}"
    (cd ./eclair-node/target/ && \
      ls && \
      unzip -o "./$THIS_DIST-bin.zip" && \
      mv "./$THIS_DIST" "$out")
  '';

  # Add extra maven dependencies which might not have been picked up
  #   automatically
  #
  #deps = [
  #  { path = "org/group-id/artifactId/version/file.jar"; sha1 = "0123456789abcdef"; }
  #  { path = "org/group-id/artifactId/version/file.pom"; sha1 = "123456789abcdef0"; }
  #];

  # Add dependencies on other mavenix derivations
  #
  #drvs = [ (import ../other/mavenix/derivation {}) ];

  # Override which maven package to build with
  #
  maven = maven.overrideAttrs (_: { jdk = jdk11; });

  # Override remote repository URLs and settings.xml
  #
  #remotes = { central = "https://repo.maven.apache.org/maven2"; };
  #settings = ./settings.xml;
}
