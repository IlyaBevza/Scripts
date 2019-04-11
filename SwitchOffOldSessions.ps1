
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
Write-Host "����� ����� ��������� ����������, ���� ���� ��� ������ ����� ��������� ������� ����� "$hour+" ����."
Write-Host "������� ������"
$servers="srv-mssql","srv-ps1c-02"
Write-Host "1. " $servers[0]
Write-Host "2. " $servers[1]
Write-Host "����� ������ ������ ��� ������ �� �������"
$answer=Read-Host "��� �����: "
switch ($answer) 
{
    1 { $server1C=$servers[0]; break;}
    2 { $server1C=$servers[1]; break; }
    Default {return;}
}
Write-Host "����� ������� ������ �� ���� ���?"
Write-Host "1. ��, �� ���� �����"
Write-Host "2. ���, ����� ������� ����."
Write-Host "3. ����� �� ���������"
$answer= Read-Host "��� �����: "
$restart_service= $false
if ($answer -ne 1 -and $answer -ne 2)
{
    return 
}
if ($answer -eq 2)
{
    $string_of_bases =Read-Host "������� ����. ���� �� ���������, �� ������� �� ����� �������:"
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
        Write-Host "�������� �����" $session.InfoBase.Name $session.UserName  $session.StartedAt
        $AgentConnection.TerminateSession($Cluster,$session)
    }
}
if($restart_service -eq $true)
{
	Stop-Service *1c*
	Wait-Event -Timeout 10
	Start-Service *1c*
	Get-Service *1c* | ForEach-Object{
		$status= "�� ��������"
		if ($_.Status -eq "Running"){
			$status="��������"
		}
		Write-Host "������ " $_.Name ":  " $status
	}
}
Read-Host





