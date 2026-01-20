# Read list of filenames (without .md)
$files = Get-Content "fileswithtags.txt" | Where-Object { $_.Trim() -ne "" }

foreach ($name in $files) {

    $file = "$name.md"

    if (-not (Test-Path $file)) {
        Write-Host "Skipping missing file: $file"
        continue
    }

    $raw = Get-Content $file -Raw

    # Normalize to LF
    $raw = $raw -replace "`r`n", "`n"

    if ($raw -match "^---\n") {

        # Split into front‑matter and body
        $parts = $raw -split "^---\n", 2
        $afterStart = $parts[1] -split "\n---\n", 2

        $front = $afterStart[0]
        $body  = $afterStart[1]

        # Remove inline tags like #tagname (word characters only)
        $body = $body -replace "(?<!\w)#\w+", ""

        $new = "---`n$front`n---`n$body"
    }
    else {

        # No front‑matter → clean whole file
        $new = $raw -replace "(?<!\w)#\w+", ""
    }

    # Write LF only
    Set-Content -Path $file -Value $new -NoNewline
}