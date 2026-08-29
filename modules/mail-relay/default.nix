{ config, pkgs, ... }:
{
  age.secrets."gmail-smtp-password".file = ./gmail-smtp-password.age;
  age.secrets."gmail-smtp-address".file = ./gmail-smtp-address.age;

  environment.systemPackages = [ pkgs.msmtp ];

  services.mail.sendmailSetuidWrapper = {
    program = "sendmail";
    source = "${pkgs.msmtp}/bin/sendmail";
    setuid = false;
    setgid = false;
    owner = "root";
    group = "root";
  };

  # /etc/msmtprc and /etc/aliases are assembled here (as real files, not via
  # environment.etc) so the gmail address is only ever read from the
  # runtime-decrypted agenix secret, never embedded in the Nix store.
  # Mail to "root" (smartd's default recipient, and anything else on the
  # system) gets aliased to the real address via msmtp's aliases file.
  system.activationScripts.msmtprc = {
    text = ''
      address="$(cat ${config.age.secrets."gmail-smtp-address".path})"

      (
      umask 177
      cat > /etc/msmtprc <<CONF
      defaults
      port 587
      tls on
      aliases /etc/aliases

      account default
      host smtp.gmail.com
      auth on
      user $address
      from $address
      passwordeval "cat ${config.age.secrets."gmail-smtp-password".path}"
      CONF
      )

      cat > /etc/aliases <<CONF
      root: $address
      CONF
    '';
    deps = [ "agenixInstall" ];
  };
}
