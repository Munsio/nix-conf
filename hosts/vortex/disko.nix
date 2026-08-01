{...}: {
  flake.nixosModules.vortex-disko = {
    disko.devices = {
      disk = {
        os = {
          type = "disk";
          device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_500GB_S466NX0M758355V";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = ["umask=0077"];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];
                  subvolumes = {
                    "@" = {
                      mountpoint = "/";
                      mountOptions = ["noatime"];
                    };
                    "@home" = {
                      mountpoint = "/home";
                      mountOptions = ["noatime"];
                    };
                    "@nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["noatime"];
                    };
                    "@log" = {
                      mountpoint = "/var/log";
                      mountOptions = ["noatime"];
                    };
                  };
                };
              };
            };
          };
        };

        data = {
          type = "disk";
          device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_M.2_1TB_S415NB0M506678Z";
          content = {
            type = "gpt";
            partitions = {
              data = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/data";
                };
              };
            };
          };
        };
      };
    };
  };
}
