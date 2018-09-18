Write-Host Выберите номер базы, которую надо восстановить:
Write-Host 1. Бухгалтерия пердприятия
Write-Host 2. ЗУП
Write-Host 3. Взаимодействие
Write-Host 4. Выйти из программы

$baseNumber=0
$baseName=""
$loop=1
while($loop -eq 1){
	$baseNumber= Read-Host "Ваш выбор: "
	switch ($baseNumber){
	1 {$baseName="buh_promservis"; $loop=0}
	2 {$baseName ="hrm_promservis" ; $loop=0}
	3 {$baseName="bp_promservis" ; $loop=0}
	4 {$loop=2}
	Default {
		Write-Host Неверный выбор. пробуйте ещё или нажмите на 4 для выхода
		}
	}
}
if ($loop -eq 0)
 {
	 Write-Host "Вы выбрали " $baseName
	 $path="\\Srv-mssql01\f\Backup"
	 $filter="*"+$baseName+"*.bak"
	 $file=Get-ChildItem -Path $path -Recurse -File -Include $filter | Sort-Object CreationTime -Descending |Select-Object -First 1
	 try{
		Copy-Item $file "D:\Temp"
		Write-Host Копирование завершено
		Pause
	 }
	 catch{
		 Write-Warning Не удалось скопировать файл
		 Pause
	 }
	 
	 

 }
