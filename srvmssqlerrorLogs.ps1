$now= Get-Date
$newdate=$now.Date
Write-Host "----------------- MSSQL   SERVER-----------------------------------"
Write-Host "------------------------System Errors------------------------------"
Get-EventLog -LogName System -ComputerName srv-mssql01 -After $newdate -EntryType Error |Select-Object -First 20| Format-List
Write-Host "------------------------Application Errors------------------------"
Get-EventLog -LogName Application -ComputerName srv-mssql01 -After $newdate -EntryType Error |Select-Object -First 20| Format-List
Write-Host "///////////////////////////////////////////////////////////////////////////////////////////////"
Write-Host "-----------------1C     SERVER------------------------------------"
Write-Host "------------------------System Errors-----------------------------"
Get-EventLog -LogName System -ComputerName srv-mssql -After $newdate -EntryType Error |Select-Object -First 20| Format-List
Write-Host "------------------------Application Errors----------------------"
Get-EventLog -LogName Application -ComputerName srv-mssql -After $newdate -EntryType Error |Select-Object -First 20| Format-List
Read-Host