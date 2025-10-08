# Konversi SHA1 fingerprint ke Base64 untuk Facebook Key Hash
$sha1 = "71:CF:5C:E8:25:45:EF:D6:D9:D7:8E:07:34:C7:FB:34:D4:86:4C:63"

# Hapus tanda ":" dan convert ke hex bytes
$hexString = $sha1.Replace(":", "")

# Convert hex string ke byte array
$bytes = [byte[]]::new($hexString.Length / 2)
For ($i = 0; $i -lt $hexString.Length; $i += 2) {
    $bytes[$i / 2] = [convert]::ToByte($hexString.Substring($i, 2), 16)
}

# Convert ke Base64
$base64 = [System.Convert]::ToBase64String($bytes)

Write-Host "SHA1 Fingerprint: $sha1"
Write-Host "Base64 Key Hash: $base64"
Write-Host ""
Write-Host "🔑 Gunakan Key Hash ini di Facebook Developer Console:"
Write-Host "$base64" -ForegroundColor Green