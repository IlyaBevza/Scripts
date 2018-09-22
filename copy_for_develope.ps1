
function Generate_SQL_Script {
  param ($source,$backup_file)
   $template=New-Object System.Text.StringBuilder
   $template.Append("USE [master]
   RESTORE DATABASE [ЦелеваяБаза] 
   FROM  DISK = N'ПутьКБазе'
    WITH  FILE = 1,  
    MOVE N'ИсходнаяБаза' TO N'D:\Bases\ЦелеваяБаза.mdf', 
    MOVE N'ИсходнаяБаза_log' TO N'D:\Logs\ЦелеваяБаза_log.ldf', 
    NOUNLOAD,  REPLACE,  STATS = 5
   GO")
   $destinationBase= DestinationBase -source $source
   if ($null -eq $destinationBase) 
       {
           Write-Host "Не удалось определить базу восстановления"
           Pause
           exit
       }
   $template.Replace("ЦелеваяБаза", $destinationBase)
   $template.Replace("ИсходнаяБаза", $source)
   $template.Replace("ПутьКБазе", $backup_file)
   $sql_script= $env:USERPROFILE + "\Desktop\Restore_backup.sql"
   Write-Host $sql_script
   $template.ToString() > $sql_script
   Start-Process $sql_script	
}
function DestinationBase ($source){
    switch ($source)
    {
        buh_promservis{ return "test_buh"}
        hrm_promservis {return "zup_test"}
        bp_promservis {return "vz_bevza"}
        default {return $null}
    }
 }

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
	 Write-Host "Копирую файл..."
     Copy-Item $file.FullName "D:\Temp"
     Write-Host "Копирование завершено."
     Write-Host "Формирую скрипт SQL для восстановления бэкапа"
     $null= Generate_SQL_Script -source $baseName -backup_file $file.Name
     Pause      
 }




 

