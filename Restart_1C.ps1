Write-Host "Перестартовать службу 1С? Задача будет сделана на БОЕВОМ сервере!"
Write-Host "Да == 1 ;Нет == Любая другая кнопка"
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
    Write-Host "Задача выполнена успешно"
} else {
    Write-Host "ВНИМАНИЕ! Не удалось запустить службу 1С. Проверьте настройки!"
}