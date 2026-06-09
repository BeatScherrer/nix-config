{ pkgs, ... }:
let
  # Bitwarden Password Manager, pinned to 2026.3.0.
  #
  # The 2026.4.x line reintroduced a Firefox/LibreWolf passkey-interception
  # regression (bitwarden/clients#20743): the extension stops hooking
  # navigator.credentials, so passkey logins fall through to LibreWolf's native
  # WebAuthn dialog, which only surfaces hardware keys and native-messaging
  # providers (1Password) — Bitwarden silently drops out. 2026.3.0 (2026-04-02)
  # is the last build before that rework. Revisit once a release past 2026.5.0
  # ships the fix, then bump url + hash (or drop this pin entirely).
  bitwardenXpi = pkgs.fetchurl {
    url = "https://addons.mozilla.org/firefox/downloads/file/4749958/bitwarden_password_manager-2026.3.0.xpi";
    hash = "sha256-LcbQdNTcCr0qiWb1BlpV5yUrv15Usjwx2+2r+sDU28Q=";
  };
in
{
  programs.librewolf = {
    enable = true;

    # Enterprise policy is baked into the wrapped package; it does not touch the
    # existing ~/.librewolf profile, session, or settings.
    policies = {
      ExtensionSettings = {
        # Bitwarden Password Manager (Firefox add-on GUID)
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          installation_mode = "force_installed";
          install_url = "file://${bitwardenXpi}";
          updates_disabled = true;
        };
      };
    };
  };
}
