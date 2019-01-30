#type - ограничения местонахождения баз. A - без ограничений, S - на сервере, F - файловые базы
function Get_Bases_1C ($type, $servername='File=')
{
    $type=$type.ToUpper()
    $path= $env:APPDATA +"\1C\1CEStart\ibases.v8i"
    $bases= @()
     if ((Test-Path -Path $path) -ne "True")
     {
         Write-Host "файл ibases.v8i не найден"
         return $bases
     } 

     
     $types="Ref=","File="
     if ($type -eq "S"){
        $types=@("Ref=")
     }elseif ($type -eq "F") {
        $types=@("File=")
     }

     foreach ($line in  (Get-Content -Path $path))
     {
         if(($line -match $servername) -ne  'True'){
            continue
         }
        foreach ($arr_elem in $types){
           if($line -match $arr_elem){
                $temp=$line -match  $arr_elem +'.*"'
                $base_path= (($Matches[0]).Replace($arr_elem,'')).Trim('"')
                if ($bases -notcontains $base_path)
                {
                    $bases+=$base_path
                }  
                break
            } 
        }
     }
    return $bases
}
# Проверяет, зарегистрирована ли база на определенном сервере
function  BaseExistsOnServer {
    param (
        $server_name, $base_name
    )
    $path= $env:APPDATA +"\1C\1CEStart\ibases.v8i"
    if ((Test-Path -Path $path) -ne "True")
    {
         Write-Host "Файл ibases.v8i не найден"
         return "False"
     } 
    
     foreach ($line in  (Get-Content -Path $path))
     {
        if($line -match $server_name+'.*"'+$base_name){
            return 'True'
        }
     }
     return 'False'
}