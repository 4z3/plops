let

hostPkgs = import <nixpkgs> {};
importJson = hostPkgs.lib.importJSON;

krops = hostPkgs.fetchgit {
  "url" = "https://cgit.krebsco.de/krops/";
  "rev"= "2e93a93ac264a480b427acc2684993476732539d";
  "sha256"= "1s6b2cs60xa270ynhr32qj1rcy3prvf9pidap0qbbvgg008iafxk";
};

lib = import "${krops}/lib";
pkgs = import "${krops}/pkgs" {};

# interface to krops
core = {

  populate = target: sources:
  pkgs.writeDash "populate-${target.host}" /* sh */ ''
  ${pkgs.populate {
      inherit target;
      force = true;
      source = lib.evalSource [ sources ];
    }}
  '';

  jobs = name: listOfJobs:
  pkgs.writeShellScriptBin name /* sh */ ''
  set -eu
  ${lib.concatStringsSep "\n" (map toString listOfJobs)}
  '';

  switch = target:
  pkgs.writeDash "switch-${target.host}" /* sh */ ''
  set -eu
  ${pkgs.openssh}/bin/ssh \
                  ${target.user}@${target.host} -p ${target.port} \
                  nixos-rebuild switch \
                  -I ${target.path} \
                  -I "/run/keys"
  '';
};

# high level syntax sugar
ops = {

  populate = sources: target:
  core.populate target sources;

  switch = target:
  core.switch target;

  jobs = name: target: listOfJobs:
  ops.jobs' name (lib.mkTarget target) listOfJobs;

  jobs' = name: target: listOfJobs:
  core.jobs name (map (elem: elem target) listOfJobs);

  populateTmpfs = sources: target:
  with lib;
  let
    tmpfs = "/run/keys/";
  in
  core.populate (target // { path = tmpfs; }) sources;

};

in
{
  inherit lib pkgs core importJson;
  inherit (ops) populate switch jobs populateTmpfs;
}
