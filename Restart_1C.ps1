Write-Host "�������������� ������ 1�? ������ ����� ������� �� ������ �������!"
Write-Host "�� == 1 ;��� == ����� ������ ������"
$answer = Read-Host 
if($answer -ne 1){
    return
}
$remPC= "srv-mssql"
$service= Get-Service -ComputerName $remPC -Name "1C:Enterprise*"
if( $service.Status -eq "Running"){
    Stop-Service -ComputerName $remPC -Name $service.Name
}
Stop-Process -ComputerName $remPC -Name "rphost"
Start-Service -ComputerName $remPC -Name $service.Name

Get-Service -ComputerName $remPC -Name $service.Name
if( $service.Status -eq "Running"){
    Write-Host "������ ��������� �������"
} else {
    Write-Host "��������! �� ������� ��������� ������ 1�. ��������� ���������!"
}