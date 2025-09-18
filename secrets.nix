let
  cave = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICh8aQnldDTbg1K9nrC2NaZ8ojz41n/Yw14W9M0P+VtM root@cave";
in
{
  "navidrome.acme.age".publicKeys = [ cave ];
  "cloudflared.age".publicKeys = [ cave ];
}
