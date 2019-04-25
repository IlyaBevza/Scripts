Write-Host "�������� ������ 1� (������ �����) �� ������ ��� ������� ������"
Write-Host "1. ������ ������"
Write-Host "2. ������ �������������"
Write-Host "3. ����� �� �������"

$choice=Read-Host "��� �����: "
$server = $choice
switch ($choice) {
    1 { $server="srv-mssql" }
    2 {$server = "srv-1c-dev"}
    3 {exit}
    Default {$server=$choice}
}

$service = Get-Service -ComputerName $server -Name *1C*

$service

Write-Host "��� ����� ������� �� �������?"
Write-Host "1. �������������� �"
Write-Host "2. ���������� ��"
Write-Host "3. ��������� �"
Write-Host "����� ������ ������ - ����� �� �������"

$choice=Read-Host "��� �����: "
switch ($choice) {
    1 { 
		Stop-Service $service
		Wait-Event -Timeout 10
		Start-Service $service
	   }
    2 {
        if ($service.Status -ne "Stopped"){
            Stop-Service $service
        }
    }
    3 {
        if ($service.Status -ne "Running"){
            Start-Service $service}
    }
    Default {exit}
}