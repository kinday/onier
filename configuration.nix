{
  inputs,
  modulesPath,
  lib,
  pkgs,
  ...
}:
let
  teruelSshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMBtPiRyLbnQcA77rILMPNebKXDjL6lAHq7ZC3Ael/hs";
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;

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

  users.users.root.openssh.authorizedKeys.keys = [ teruelSshKey ];

  # Enable podman & podman systemd generator
  virtualisation.quadlet.enable = true;
  users.groups.podbot = { };
  users.users.podbot = {
    # required for rootless container with multiple users
    autoSubUidGidRange = true;
    createHome = true;
    group = "podbot";
    home = "/home/podbot";
    isSystemUser = true;
    # required for auto start before user login
    linger = true;
    openssh.authorizedKeys.keys = [ teruelSshKey ];
    shell = pkgs.bashInteractive;
  };

  home-manager.users.podbot =
    { pkgs, config, ... }:
    {
      imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];
      virtualisation.quadlet.enable = true;
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

      # This value determines the Home Manager release that your configuration is
      # compatible with. This helps avoid breakage when a new Home Manager release
      # introduces backwards incompatible changes.
      #
      # You should not change this value, even if you update Home Manager. If you do
      # want to update the value, then make sure to first check the Home Manager
      # release notes.
      home.stateVersion = "25.11"; # Please read the comment before changing.
    };

  system.stateVersion = "24.05";
}
