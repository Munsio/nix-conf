{...}: {
  flake.nixosModules.amdgpu = {
    boot.initrd.kernelModules = ["amdgpu"];

    hardware.graphics.enable = true;
  };
}
