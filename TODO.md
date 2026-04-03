# TODO

## Add all hosts as agenix recipients in secrets.nix

Currently only `cave`'s root SSH host key is declared in `secrets.nix`, so secrets
can only be decrypted on cave. To allow future secrets to target other hosts,
collect their SSH host keys and add them.

### How to collect the keys

```bash
# on each machine, or remotely:
cat /etc/ssh/ssh_host_ed25519_key.pub

# or via ssh-keyscan if reachable:
ssh-keyscan -t ed25519 fourforty 2>/dev/null | awk '{print $2, $3}'
ssh-keyscan -t ed25519 firefly 2>/dev/null | awk '{print $2, $3}'
```

**monolith** has openssh server disabled so no host key exists. Options:
- Enable openssh temporarily to generate the key, then disable it again.
- Use the user key (`~/.ssh/id_ed25519.pub`) as the recipient instead.

### What to update

Add the collected keys to `secrets.nix` and re-key all existing secrets:

```nix
let
  cave     = "ssh-ed25519 AAAA... root@cave";
  monolith = "ssh-ed25519 AAAA... root@monolith"; # or user key
  fourforty = "ssh-ed25519 AAAA... root@fourforty";
  firefly  = "ssh-ed25519 AAAA... root@firefly";
  all = [ cave monolith fourforty firefly ];
in
{
  "navidrome.acme.age".publicKeys  = [ cave ];
  "copyparty.acme.age".publicKeys  = [ cave ];
  "cloudflared.age".publicKeys     = [ cave ];
  "copyparty.bruno.age".publicKeys = [ cave ];
}
```

After updating `secrets.nix`, re-key existing secrets:

```bash
agenix --rekey
```
