$server= Read-Host "Укажите имя компьютера. По умолчанию - это текущий комп"
if($server -eq '')
{
    $server= $env:COMPUTERNAME
}
gps -ComputerName $server | sort WS -Descending | select -First 5