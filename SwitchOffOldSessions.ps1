
. ".\v8i_Reader.ps1"

function isInBase([string[]]$baseArray, $baseName){
    if($baseArray.Length -eq 0){
         return 1
    }
    foreach ($base in $baseArray){
        if($base.Trim() -eq ""){
            continue
        }
        if($base -eq $baseName){
            return 1
        }
    }
    return 0
}

$hour =3
Write-Host "Сеанс будет считаться устаревшим, если дата его начала ранее текущеего времени минус "$hour+" часа."
Write-Host "Укажите сервер"
$servers="srv-mssql","srv-ps1c-02"
Write-Host "1. " $servers[0]
Write-Host "2. " $servers[1]
Write-Host "Любой другой символ для выхода из скрипта"
$answer=Read-Host "Ваш выбор: "
switch ($answer) 
{
    1 { $server1C=$servers[0]; break;}
    2 { $server1C=$servers[1]; break; }
    Default {return;}
}
Write-Host "Нужно удалить сеансы со всех баз?"
Write-Host "1. Да, по всем базам"
Write-Host "2. Нет, будет указана мною."
Write-Host "3. Выйти из программы"
$answer= Read-Host "Ваш выбор: "
$restart_service= $false
if ($answer -ne 1 -and $answer -ne 2)
{
    return 
}
if ($answer -eq 2)
{
    $string_of_bases =Read-Host "Введите базу. если их несколько, то укажите их через пробелы:"
    $bases=$string_of_bases.Split(' ')
}else{
    $bases= Get_Bases_1C 's' $server1C
	$restart_service= $true
}

$connection=New-Object -ComObject V83.COMConnector
$AgentConnection = $connection.ConnectAgent($server1C)
$Cluster = $AgentConnection.GetClusters()[0]
$AgentConnection.Authenticate($Cluster,"","")
$sessions= $AgentConnection.GetSessions($Cluster)
$limit=(Get-Date).AddHours(-$hour)
foreach ($session in $sessions)
{
    if ((isInBase $bases $session.InfoBase.Name) -eq 0)
    {
        continue
    }
    if($session.StartedAt -le $limit)
    {
        Write-Host "Завершен сеанс" $session.InfoBase.Name $session.UserName  $session.StartedAt
        $AgentConnection.TerminateSession($Cluster,$session)
    }
}
if($restart_service -eq $true)
{
	Stop-Service *1c*
	Wait-Event -Timeout 10
	Start-Service *1c*
	Get-Service *1c* | ForEach-Object{
		$status= "Не запущена"
		if ($_.Status -eq "Running"){
			$status="Запущена"
		}
		Write-Host "Служба " $_.Name ":  " $status
	}
}
Read-Host





