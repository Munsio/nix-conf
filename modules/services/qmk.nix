{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    qmk
    via
  ];

  services.udev.packages = with pkgs; [
    qmk-udev-rules
    via
  ];

  hardware.keyboard.qmk.enable = true;
}
