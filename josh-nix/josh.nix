{ lib
, stdenv
, fetchFromGitHub
, fetchNpmDeps
, npmHooks
, fetchpatch
, rustPlatform
, libgit2
, nodejs
, openssl
, pkg-config
, makeWrapper
, git
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "josh";
  version = "23.02.14";
  JOSH_VERSION = "r${version}";

  src = fetchFromGitHub {
    owner = "esrlabs";
    repo = "josh";
    rev = JOSH_VERSION;
    sha256 = "1sqa8xi5d55zshky7gicac02f67vp944hclkdsmwy0bczk9hgssr";
  };

  patches = [
    # Unreleased patch allowing compilation from the GitHub tarball download
    (fetchpatch {
      name = "josh-version-without-git.patch";
      url = "https://github.com/josh-project/josh/commit/13e7565ab029206598881391db4ddc6dface692b.patch";
      sha256 = "1l5syqj51sn7kcqvffwl6ggn5sq8wfkpviga860agghnw5dpf7ns";
    })
  ];

  npmDeps = fetchNpmDeps {
    name = "${pname}-npm-deps";
    inherit src;
    sourceRoot = "source/josh-ui";
    hash = "sha256-AN4GfcPD2XwgYa/CnY/28DbPSKoCyBub4wH6/lrljmo=";
  };

  npmRoot="josh-ui";

  cargoSha256 = "0f6cvz2s8qs53b2g6xja38m24hafqla61s4r5za0a1dyndgms7sl";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    nodejs
    npmHooks.npmConfigHook
  ];

  outputs = [ "out" "web" ];

  buildInputs = [
    libgit2
    openssl
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.Security
  ];

  postInstall = ''
    mv scripts/git-sync $out/bin
    wrapProgram "$out/bin/josh-proxy" --prefix PATH : "${git}/bin"
    wrapProgram "$out/bin/git-sync" --prefix PATH : "${git}/bin"

    mkdir -p $web
    mv static/* $web
  '';

  passthru = {
    shellPath = "/bin/josh-ssh-shell";
  };

  meta = {
    description = "Just One Single History";
    homepage = "https://josh-project.github.io/josh/";
    downloadPage = "https://github.com/josh-project/josh";
    changelog = "https://github.com/josh-project/josh/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [
      lib.maintainers.sternenseemann
      lib.maintainers.tazjin
    ];
    platforms = lib.platforms.all;
  };
}
