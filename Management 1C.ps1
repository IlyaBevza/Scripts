function termintate_sessions ($base_name,$cluster_of_server,$cur_connections)
{
    $sessions1CtoTerminate = ($cur_connections.GetSessions($cluster_of_server) | 
    Where-Object {$_.Infobase.Name -eq $base_name -and $_.AppId -ne "srvrConsole" -and $_.AppId -ne "BackgroundJob" -and $_.AppId -ne "designer"})
    foreach ($session in $sessions1CtoTerminate){
        $AgentConnection.TerminateSession($cluster_of_server,$session)
    }
}

function changeConnectDenied([string]$base, [bool]$ConnectDenied, $ServerAgent,$Claster)
{
   if($base -eq "bp_promservis"){
        $User="Бевза И.Н."
   }elseif($base -eq "vz_bevza"){
    $User="Бевза И.Н."
    } else{
    $User = "Бевза"
   }
  $Pass = Read-Host -AsSecureString "Укажите пароль:"
  $now= Get-Date
    if($ConnectDenied -eq $true){
        $Midnight=$now.Date
        $From=Read-Host "Укажите время начала блокировки сеансов в формате HHmm"
        $To =Read-Host "Укажите время окончания блокировки сеаносв в формате HHmm"
        $TimeFrom=$Midnight.AddHours($From.Substring(0,2))
        $TimeFrom=$TimeFrom.AddMinutes($From.Substring(2,2))
        $TimeTo = $Midnight.AddHours($To.Substring(0,2))
        $TimeTo = $TimeTo.AddMinutes($To.Substring(2,2))
    } else{
        $TimeFrom= $now.AddHours(-3)
        $TimeTo = $now
    }
   
     # Получаем список рабочих процессов кластера
     $WorkingProcesses = $ServerAgent.GetWorkingProcesses($Claster)

    foreach ($WorkingProcess in $WorkingProcesses)
    {                    
        if (!($WorkingProcess.Running -eq 1))
        {
            continue
        }    
        $CWPAddr = "tcp://"+$WorkingProcess.HostName+":"+$WorkingProcess.MainPort
        $CWP = $connector.ConnectWorkingProcess($CWPAddr)
        
        $CWP.AuthenticateAdmin("", "") 
        $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($Pass)
        $PassToStr = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
        [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
        $CWP.AddAuthentication($User, $PassToStr) 
        $InfoBases = $CWP.GetInfoBases()

        foreach ($InfoBase in $InfoBases)
        {
            if ($InfoBase.Name -eq $base)
            {
                $InfoBaseFound = $TRUE  
                # Устанавливаем/снимаем блокировку соединений ИБ
                $InfoBase.SessionsDenied = $ConnectDenied
                $InfoBase.PermissionCode = "design"
                $InfoBase.DeniedMessage ="Сеанс завершён администратором систмеы"
                $InfoBase.DeniedFrom =$TimeFrom.ToString("yyyy-MM-dd HH:mm:ss")
                $InfoBase.DeniedTo =$TimeTo.ToString("yyyy-MM-dd HH:mm:ss")
                $CWP.UpdateInfoBase($InfoBase)

                break
            }
        }
        
        if (!($InfoBaseFound))
        {
            write-host "Не найдена указанная в параметрах запуска ИБ..."
            break
        }

      
    }
}


$connector= New-Object -ComObject V83.COMConnector
Write-Host "Выберите сервер 1С"
Write-Host "1. Боевой"
Write-Host "2. Srv-ps1c-02"
Write-Host "3. Srv-1c-dev"
Write-Host "4. Произвольное имя сервера"
Write-Host "5. Выход их скрипта"

$workserver="srv-mssql"
$dev1_server="srv-ps1c-02"
$dev2_server="srv-1c-dev"
$choice = Read-Host "Ваш выбор: "
$server1C=$choice
switch ($choice) {
    1 {$server1C= $workserver}
    2 {$server1C=$dev1_server}
    3 {$server1C= $dev2_server}
    4 {$server1C=$choice}
    Default {exit}
}

Write-Host "Выберите базу"
Write-Host "1. Бухгалтерия"
Write-Host "2. ЗУП"
Write-Host "3. Взаимодействие"
Write-Host "4. Другая база"
Write-Host "5. Выход их скрипта"

$choice =Read-Host "Ваш выбор: "
$base=$choice
if ($choice -eq 5){
    exit
}
if ($server1C -eq $workserver){
    switch ($choice) {
        1 {$base="buh_promservis"}
        2 {$base ="hrm_promservis"}
        3 {$base="bp_promservis"}
        Default {$base=$choice}
    }  
}
if ($server1C -eq $dev1_server){
    switch ($choice) {
        1 {
             Write-Host "На данном сервере базы бухгалтерии нет. Сервер изменен на " $dev2_server
             $server1C = $dev2_server
             $base="test_buh"
            }
         2 {$base="zup_test"}  
         3 {$base ="vz_bevza"} 
         Default {$base=$choice}
    }
}

if ($server1C -eq $dev2_server){
    switch ($choice) {
        1 {$base="test_buh"} 
        2 {
            Write-Host "На данном сервере нет базы ЗУП. Сервер изменен на " $dev1_server
            $server1C = $dev1_server
            $base="zup_test"
        }       
        3 {
            Write-Host "На данном сервере нет базы Взаимодействие Сервер изменен на " $dev1_server
            $server1C = $dev1_server
            $base ="vz_bevza"
        }   
        Default {$base=$choice}
    }
}

$AgentConnection = $connector.ConnectAgent($server1C)
$Cluster = $AgentConnection.GetClusters()[0]
$AgentConnection.Authenticate($Cluster,"","")

Write-Host  "Выберите, что нужно сделать"
Write-Host  "1. Закрыть все сессии"
Write-Host  "2. Установить время ограничения работы"
Write-Host  "3. Снять время ограничения работы"
Write-Host  "Любая другая кнопка. Выйти из программы"
$choice = Read-Host "Ваш выбор:"
switch ($choice) {
    1 { 
        termintate_sessions $base $Cluster $AgentConnection
     }
     2{
        changeConnectDenied $base $true $AgentConnection $Cluster
     }
     3{
        changeConnectDenied $base $false $AgentConnection $Cluster
     }
    Default {exit}
}


