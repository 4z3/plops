{ pkgs ?  import <nixpkgs> {} }:
let

  # todo this should be automatic at some point in time
  createReadme = pkgs.writeShellScriptBin "create-readme" /* sh */ ''
  ${pkgs.pandoc}/bin/pandoc \
                 -s \
                 ${toString ./doc/10_intro.md} \
                 ${toString ./doc/20_example.md} \
                 ${toString ./example/shell.nix} \
                 ${toString ./doc/21_example.md} \
                 ${toString ./doc/50_tmpfs.md} \
                 -f markdown -t markdown \
                 -o ${toString ./README.md}
  '';
in
pkgs.mkShell {

  buildInputs = with pkgs; [
    pkgs.haskellPackages.pandoc
    createReadme
  ];

  shellHook = ''
    HISTFILE=${toString ./.}/.history
  '';
}
