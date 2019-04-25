Write-Host "Выберите сервер 1С (указав номер) из списка или укажите другой"
Write-Host "1. Боевой сервер"
Write-Host "2. Сервер разработчиков"
Write-Host "3. Выйти из скрипта"

$choice=Read-Host "Ваш выбор: "
$server = $choice
switch ($choice) {
    1 { $server="srv-mssql" }
    2 {$server = "srv-1c-dev"}
    3 {exit}
    Default {$server=$choice}
}

$service = Get-Service -ComputerName $server -Name *1C*

$service

Write-Host "Что нужно сделать со службой?"
Write-Host "1. Перестартовать её"
Write-Host "2. Остановить ёё"
Write-Host "3. Запустить её"
Write-Host "Любой другой символ - Выйти из скрипта"

$choice=Read-Host "Ваш выбор: "
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