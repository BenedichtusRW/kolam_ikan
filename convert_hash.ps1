# Script to convert SHA-1 fingerprint to Base64 Key Hash for Facebook
$sha1 = "71:CF:5C:E8:25:45:EF:D6:D9:D7:8E:07:34:C7:FB:34:D4:86:4C:63"
$hexBytes = $sha1 -split ':' | ForEach-Object { [Convert]::ToByte($_, 16) }
$base64 = [System.Convert]::ToBase64String($hexBytes)
Write-Host "SHA-1 Fingerprint: $sha1"
Write-Host "Base64 Key Hash: $base64"