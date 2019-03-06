$now=Get-Date
$after= $now.AddDays(-3)
$after=$after.Date
Write-Host "Вывод данных об ошибках за 3 дня"
Write-Host "============================================="
Write-Host "============= Текущий компьютер ============="
Get-EventLog -LogName Application -EntryType Error -Before $now -After $after
#Get-EventLog -LogName System -EntryType Error -Before $now -After $after
$servers="srv-mssql01","srv-mssql","srv-ps1c-02","srv-1c-dev"
foreach ($server in $servers)
{
    Write-Host "=============================================="
    Write-Host "============= Сервер " $server " ============="
    Get-EventLog -ComputerName $server  -LogName Application -EntryType Error -Before $now -After $after
    #Get-EventLog -ComputerName $server  -LogName System -EntryType Error -Before $now -After $after

}
