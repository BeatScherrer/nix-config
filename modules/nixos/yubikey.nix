{ pkgs, ... }:
{
  # NOTE: to register the yubikey:
  # 1. nix-shell -p pam_u2f
  # 2. mkdir -p ~/.config/Yubico
  # 3. pamu2fcfg > ~/.config/Yubico/u2f_keys
  # 4. (optional) add another yubikey (optional): pamu2fcfg -n >> ~/.config/Yubico/u2f_keys

  services.udev.packages = [ pkgs.yubikey-personalization ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  security.pam = {
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };
    # Having that, you should be able to use your Yubikey to login and for sudo. You can also set security.pam.yubico.control to "required" in order to have multi-factor authentication.
    # 1. nix-shell -p yubico-pam -p yubikey-manager
    # 2. ykman otp chalresp --touch --generate 2
    # 3. ykpamcfg -2 -v
    yubico = {
      enable = true;
      debug = true;
      mode = "challenge-response";
      id = [ "TODO" ]; # nix-shell --command 'ykinfo -s' -p yubikey-personalization
    };
  };

}
