{ lib, ... }:
{
  disko.devices = {
    disk = {
      primary = {
        device = lib.mkDefault "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512MiB";
              type = "EF00";
              priority = 1;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              type = "8300";
              size = "100%";
              priority = 2;
              content = {
                type = "filesystem";
                format = "ext4";
              };
            };
          };
        };
      };
    };
  };
}
