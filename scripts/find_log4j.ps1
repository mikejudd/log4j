## Kudos to Matt Dewa4t in MSPGeek Slack

$drives = Get-PSDrive -PSProvider FileSystem |Where-Object { $_.free -gt 0 } | Select-Object -ExpandProperty root
$detected = @()
foreach ($drive in $drives) {
    $robocopyexitcode = (Start-Process robocopy  -ArgumentList "$drive c:\DOESNOTEXIST *.jar *.war *.ear /S /XJ /L /FP /NS /NC /NDL /NJH /NJS /r:0 /w:0 /LOG:$env:temp\log4jfilescan.csv" -Wait).exitcode
    if ($? -eq $True) {
        $log4jfilescan = Import-Csv "$env:temp\log4jfilescan.csv" -Header FilePath -Delimiter '?'   
        $detected += $log4jfilescan
        Remove-Item "$env:temp\log4jfilescan.csv"
    }
}
If ($detected) {
    $vulnerablefiles = $detected | ForEach-Object { Select-String "JndiLookup.class" $_.FilePath } | Select-Object -exp Path | Sort-Object -Unique 
}
If ($vulnerablefiles) {
    Write-Output "Detected vulnerable files: $vulnerablefiles" 
}else {
    Write-Output "No vulnerable files detected."
}
