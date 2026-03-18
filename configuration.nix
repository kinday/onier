{
  inputs,
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-configuration.nix
  ];

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.openssh.enable = true;

  environment.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.vim
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMBtPiRyLbnQcA77rILMPNebKXDjL6lAHq7ZC3Ael/hs"
  ];

  # Enable podman & podman systemd generator
  virtualisation.quadlet.enable = true;
  users.users.podman = {
    # required for auto start before user login
    linger = true;
    # required for rootless container with multiple users
    autoSubUidGidRange = true;
  };
  home-manager.users.podman =
    { pkgs, config, ... }:
    {
      imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];
      virtualisation.quadlet.containers = {
        echo-server = {
          autoStart = true;
          serviceConfig = {
            RestartSec = "10";
            Restart = "always";
          };
          containerConfig = {
            image = "docker.io/mendhak/http-https-echo:31";
            publishPorts = [ "127.0.0.1:8080:8080" ];
            userns = "keep-id";
          };
        };
      };
    };

  system.stateVersion = "24.05";
}
