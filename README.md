# plops (palo OPs)

This is a palo (thats me) friendly
[krops](https://cgit.krebsco.org/krops)
framework.
It creates executables
which are run to trigger deployments.

The easiest way is to use it,
is to write a
[shell.nix](https://link.to.shell.nix)
which defines your deployments.

## minimal setup

```nix
let
  ops = import ((import <nixpkgs> {}).fetchgit {
    url = "https://github.com/mrVanDalo/plops.git";
    rev = "ed4308552511a91021bc979d8cfde029995a9543";
    sha256 = "0vc1wqgxz85il8az07npnppckm8hrnvn9zlb4niw1snmkd2jjzx8";
  });

  lib = ops.lib;
  pkgs = ops.pkgs;

  sources = {

    nixPkgs = {
      nixpkgs.git = {
        ref = "19.03";
        url = https://github.com/NixOS/nixpkgs-channels;
      };
      nixpkgs-unstable.git = {
        ref = "19.09";
        url = https://github.com/NixOS/nixpkgs-channels;
      };
    };

    system = name: {
      system.file = toString ./system;
      configs.file = toString ./configs;
      nixos-config.symlink = "configs/${name}/configuration.nix";
    };

    secrets = name: {
      secrets.pass = {
        dir  = toString ./secrets;
        name = "${name}/persist";
      };
    };
    keys = name: {
      keys.pass = {
        dir  = toString ./secrets;
        name = "${name}/tmpfs";
      };
    };
  };

  serverDeployment = name: {
    host ? "${name}.private",
    user ? "root"
  }:
  with ops;
  jobs "deploy-${name}" "${user}@${host}" [
    (populateTmpfs (source.keys name))
    (populate (source.secrets name))
    (populate (source.system name))
    (populate source.nixPkgs)
    switch
  ];

  servers = with lib;
  let
    serverList = [ "schasch" "kruck" "sputnik" "porani" ];
    deployments = flip map serverList  ( name:  serverDeployment name {} );
  in
  deployments;

in
pkgs.mkShell {

  buildInputs = servers;

  shellHook = ''
      export PASSWORD_STORE_DIR=./secrets
  '';
}
```

# `/run/keys`

the switch command includes also everything
in `/run/keys` which can be populated using 
`populatedTmpfs` and can be accessed via `<keys/...>`

These keys will be gone after a restart of the machine.

There is a module which makes it easy to handle
theses tmpfs-keys.
