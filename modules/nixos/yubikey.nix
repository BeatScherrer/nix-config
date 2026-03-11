{ pkgs, ... }:
{
  # NOTE: to register the yubikey:
  # 1. `nix-shell -p pam_u2f`
  # 2. `mkdir -p ~/.config/Yubico`
  # 3. `pamu2fcfg > ~/.config/Yubico/u2f_keys`
  # 4. (optional) add another yubikey (optional): pamu2fcfg -n >> ~/.config/Yubico/u2f_keys

  # NOTE: Fingerprint management:
  # List enrolled fingerprints
  # ykman fido fingerprints list
  # Add a new fingerprint (you'll need your FIDO PIN)
  # ykman fido fingerprints add "right-index" --pin YOUR_PIN
  # Delete a fingerprint
  # ykman fido fingerprints delete "right-index"

  programs.yubikey-manager.enable = true;

  environment.systemPackages = with pkgs; [
    yubikey-touch-detector
    pam_u2f
  ];

  services = {
    udev.packages = [ pkgs.yubikey-personalization ];
    pcscd.enable = true; # NOTE: Smartcard mode (CCID)
  };

  # NOTE: current YubiKey (firmware 3.0.0, USB-C keychain) only supports FIDO U2F — no OpenPGP, so GPG/SSH agent support won't use the key
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  security.pam = {
    u2f = {
      enable = true;
      # PAM control modes:
      # - "sufficient": key tap alone grants access, falls back to password if no key
      # - "required":   key tap AND password both needed (true 2FA, lockout if no key)
      # - "requisite":  key tap AND password both needed, fail immediately if no key (no fallback)
      control = "sufficient";
      settings = {
        cue = true; # prompt "Please touch the device" when waiting for tap
      };
    };
    services = {
      login.u2fAuth = true;
      sudo.u2fAuth = true;
    };

    # Having that, you should be able to use your Yubikey to login and for sudo. You can also set security.pam.yubico.control to "required" in order to have multi-factor authentication.
    # 1. `nix-shell -p yubico-pam -p yubikey-manager`
    # 2. `ykman otp chalresp --touch --generate 2`
    # 3. `ykpamcfg -2 -v`
    # yubico = {
    #   enable = true;
    #   debug = true;
    #   mode = "challenge-response";
    #   id = [ "34792894" ]; # `nix-shell --command 'ykinfo -s' -p yubikey-personalization`
    # };
  };

  # NOTE: lock the screen when a yubikey is unplugged
  # services.udev.extraRules = ''
  #   ACTION=="remove",\
  #    ENV{ID_BUS}=="usb",\
  #    ENV{ID_MODEL_ID}=="0402",\
  #    ENV{ID_VENDOR_ID}=="1050",\
  #    ENV{ID_VENDOR}=="Yubico",\
  #    RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  # '';
}
