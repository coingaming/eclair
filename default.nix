# This file has been generated by mavenix-2.3.3. Configure the build here!
let mavenix-src = fetchTarball {
      url = "https://github.com/coingaming/mavenix/tarball/f42e469732861136fced1cbfecce94f4479deeff";
      sha256 = "12a6b9r83j9kxqqvvmdjr9a1pw5mcbp0ywj8cnz8jviv2mwrnkmq";
    };
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
  debug = true;
  doCheck = false;
  infoFile = ./mavenix.lock;

  # Add build dependencies
  #
  buildInputs = [ unzip ];
  propagatedBuildInputs = [ jq jdk11 ];

  # Set build environment variables
  #
  TERM="xterm-256color";
  MAVEN_OPTS="-Dfile.encoding=UTF-8 -Dmaven.test.skip=true";

  # Attributes are passed to the underlying `stdenv.mkDerivation`, so build
  #   hooks can be set here also.
  #
  preBuild = ''
    rm -rf ./.git
    mvn clean
  '';
  installPhase = ''
    export THIS_DIST="eclair-node-0.5.1-SNAPSHOT-\''${git.commit.id.abbrev}"
    (cd ./eclair-node/target/ && \
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








# # This file has been generated by mavenix-2.3.3. Configure the build here!
# let
#   mavenix-src = fetchTarball { url = "https://github.com/nix-community/mavenix/tarball/v2.3.3"; sha256 = "1l653ac3ka4apm7s4qrbm4kx7ij7n2zk3b67p9l0nki8vxxi8jv7"; };
# in {
#   # pkgs is pinned to 19.09 in mavenix-src,
#   # replace/invoke with <nixpkgs> or /path/to/your/nixpkgs_checkout
#   pkgs ? (import mavenix-src {}).pkgs,
#   mavenix ? import mavenix-src { inherit pkgs; },
#   src ? ./.,
#   doCheck ? false,
# }:
# with pkgs;
# mavenix.buildMaven {
#   inherit src doCheck;
#   debug = true;
#   infoFile = ./mavenix.lock;
#
#   # Add build dependencies
#   #
#   #buildInputs = with pkgs; [ git makeWrapper ];
#   buildInputs = with pkgs; [ unzip ];
#   propagatedBuildInputs = with pkgs; [ jq jdk11 ];
#
#
#   # Set build environment variables
#   #
#   #MAVEN_OPTS = "-Dfile.encoding=UTF-8";
#   #TERM="xterm-256color";
#   MAVEN_OPTS="-Dfile.encoding=UTF-8";
#
#   preBuild = ''
#     rm -rf ./.git
#   '';
#   installPhase = ''
#     export THIS_DIST="eclair-node-0.5.1-SNAPSHOT-\''${git.commit.id.abbrev}"
#     (cd ./eclair-node/target/ && \
#       unzip -o "./$THIS_DIST-bin.zip" && \
#       mv "./$THIS_DIST" "$out")
#   '';
#
#   # Attributes are passed to the underlying `stdenv.mkDerivation`, so build
#   #   hooks can be set here also.
#   #
#   #postInstall = ''
#   #  makeWrapper ${pkgs.jre8_headless}/bin/java $out/bin/my-bin \
#   #    --add-flags "-jar $out/share/java/my-proj.jar"
#   #'';
#
#   # Add extra maven dependencies which might not have been picked up
#   # automatically
# #
#   #deps = [
#   #  { path = "org/group-id/artifactId/version/file.jar"; sha1 = "0123456789abcdef"; }
#   #  { path = "org/group-id/artifactId/version/file.pom"; sha1 = "123456789abcdef0"; }
#   #];
#
#   # Add dependencies on other mavenix derivations
#   #
#   #drvs = [ (import ../other/mavenix/derivation {}) ];
#
#   # Override which maven package to build with
#   #
#   maven = maven.overrideAttrs (_: { jdk = jdk11; });
#
#   # Override remote repository URLs and settings.xml
#   #
#   #remotes = { central = "https://repo.maven.apache.org/maven2"; };
#   #settings = ./settings.xml;
# }
