param (
  [string]$TargetUsername= "mateusdigital",
  [string]$TargetHostname = "mateus.digital"
)

$KEY_PATH = "$HOME/.ssh/id_ed25519";

if (-Not (Test-Path $KEY_PATH)) {
  Write-Host "Key not found - $KEY_PATH";
  exit;
}

$PubKey = Get-Content "$KEY_PATH.pub" -Raw;

ssh "$TargetUsername@$TargetHostname" "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
ssh "$TargetUsername@$TargetHostname" "echo '$PubKey' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

Write-Host "SSH key installed for $TargetUsername@$TargetHostname" -ForegroundColor Green;
