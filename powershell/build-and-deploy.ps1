$REPOS_DIR = $args[0];
if(-not (Test-Path $REPOS_DIR)) {
  Write-Error "Directory $REPOS_DIR does not exist!";
  exit 1;
}

$items = Get-ChildItem $REPOS_DIR -Directory;
foreach($item in $items) {
  Push-Location $item;
    git reset --hard;
    git pull;

    ./scripts/_full-build.ps1;
  Pop-Location;
}