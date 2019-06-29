plops (palo OPs)
================

This is a palo (thats me) friendly
[krops](https://cgit.krebsco.de/krops) framework. It creates
executables which are run to trigger deployments.

The easiest way is to use it, is to write a
[shell.nix](https://link.to.shell.nix) which defines your deployments.

minimal setup
-------------

``` {.nix}

let
  # import plops with pkgs and lib
  ops = import ((import <nixpkgs> {}).fetchgit {
    url = "https://github.com/mrVanDalo/plops.git";
    rev = "ed4308552511a91021bc979d8cfde029995a9543";
    sha256 = "0vc1wqgxz85il8az07npnppckm8hrnvn9zlb4niw1snmkd2jjzx8";
  });
  lib = ops.lib;
  pkgs = ops.pkgs;

  # define all sources
  sources = {

    # nixpkgs (no need for channels anymore)
    nixPkgs.nixpkgs.git = {
      ref = "19.03";
      url = https://github.com/NixOS/nixpkgs-channels;
    };

    # system configurations
    system = name: {
      configs.file = toString ./configs;
      nixos-config.symlink = "configs/${name}/configuration.nix";
    };

    # secrets which are hold and stored by pass
    secrets = name: {
      secrets.pass = {
        dir  = toString ./secrets;
        name = name;
      };
    };
  };

in
pkgs.mkShell {

  # define 2 servers
  buildInputs = with ops; [
    (jobs "deploy-server" "root@94.3.23.12" [
      # deploy secrets to /run/secrets
      (populateTmps (source.secrets name))
      # deploy system to /var/src/system
      (populate (source.system name))
      # deploy nixpkgs to /var/src/nixpkgs
      (populate source.nixPkgs)
      # run nixos-rebuild switch -I /var/src -I /run/secrets
      # todo : make sure that -I /run/secrets are is called
      switch
    ])
  ];

  shellHook = ''
    export PASSWORD_STORE_DIR=./secrets
  '';
}
```

tmpfs
-----

`plops` can populate your files and folders everywhere you want. It
comes with a function `populateTmpfs` which populates the files and
folders in `/run/plops-secrets/<name>`. So these keys will be gone after
a restart of the machine.

You can reference theses folder in your `configuration.nix` like all the
other sources. For this example it would be `<secrets/my-secret-key>`.

There is a module which makes it easy to handle systemd services
depending on theses tmpfs files (which are not present at boot time).
