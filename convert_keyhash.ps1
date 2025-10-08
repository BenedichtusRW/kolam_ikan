$sha1 = '71CF5CE82545EFD6D9D78E0734C7FB34D4864C63'
$hexString = $sha1 -replace ':', ''
$bytes = [byte[]]@()
for ($i = 0; $i -lt $hexString.Length; $i += 2) {
    $bytes += [Convert]::ToByte($hexString.Substring($i, 2), 16)
}
$base64 = [Convert]::ToBase64String($bytes)
Write-Host "Key Hash for Facebook: $base64"