function Generate_SQL_Script {
    param ($source)
     $template=New-Object System.Text.StringBuilder
     $template.Append("BACKUP DATABASE [SOURCE] 
     TO  DISK = N'F:\Backup\SOURCE\CurrentDate.bak' 
     WITH NOFORMAT, NOINIT,  
     NAME = N'SOURCE-Full Database Backup', 
     SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10
     GO")
    $template.Replace("SOURCE", $source)
    $date=Get-Date
    $newpath=$date.ToShortDateString()
    $newpath=$newpath.Replace(".","")
    $template.Replace("CurrentDate", $newpath)
    $sql_script= $env:USERPROFILE + "\Desktop\Set_backup.sql"
    Write-Host $sql_script
    $template.ToString() > $sql_script
    Start-Process $sql_script	
} 




Write-Host  "Выберите номер базы, которую надо восстановить:"
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
		Write-Host "Неверный выбор. пробуйте ещё или нажмите на 4 для выхода"
		}
	}
}
if ($loop -eq 0)
 {
	 Write-Host "Формирую скрипт SQL для восстановления бэкапа "+ $baseName
     $null= Generate_SQL_Script -source $baseName
     Pause      
 }
