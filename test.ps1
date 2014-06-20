$Logfile = "C:\NVSmartDetection\$(gc env:computername).log"
$found = 0

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

Try {     
    #Verify that the OS Version is 6.0 and above, otherwise the script will fail 
    If ((Get-WmiObject -ComputerName $env:COMPUTERNAME Win32_OperatingSystem -ea stop).Version -lt 6.0) { 
        Write-Warning "The Operating System of the computer is not supported.`nClient: Vista and above`nServer: Windows 2008 and above."
        Break
        } 
    } 
Catch { 
    Write-Warning "$($error[0])"
    Break
}

Try {
    [array]$users = gwmi win32_userprofile | select localpath
}          
Catch {
    Write-Warning "$($error[0])"
    Break
}

$num_users = $users.count
LogWrite "$($num_users) Profiles found on $($env:COMPUTERNAME)"
Write-Host -ForegroundColor Green "Checking for NVSmart in User Profiles"
LogWrite "Checking for NVSmart in User Profiles"

For ($i=0;$i -lt $num_users; $i++) { 
    LogWrite "Checking $($users[$i].localpath) for NVSmart"
    $user = $users[$i].localpath
    If(Test-Path $user/UdpGf -PathType Container) {
        Write-Host -ForegroundColor Red "NVSmart Found in $($users[$i].localpath)"
        LogWrite "NVSmart found in $($user)/UdpGf"
        $found = 1
    }

    If(Test-Path $user/SxS -PathType Container) {
        Write-Host -ForegroundColor Red "NVSmart Found in $($users[$i].localpath)"
        LogWrite "NVSmart found in $($user)/SxS"
        $found = 1
    }
    
}

Write-Host -ForegroundColor Green "Checking for NVSmart in All Users Profile"
LogWrite "Checking for NVSmart in All Users Profile"

If(Test-Path $env:ALLUSERSPROFILE/Gf -PathType Container) {
    Write-Host -ForegroundColor Red "NVSmart Found in  $($env:ALLUSERSPROFILE)"
    LogWrite "NVSmart Found in $env:ALLUSERSPROFILE"
    $found = 1
}

If(Test-Path $env:ALLUSERSPROFILE/SxS -PathType Container) {
    Write-Host -ForegroundColor Red "NVSmart Found in $($env:ALLUSERSPROFILE)"
    LogWrite "NVSmart Found in $env:ALLUSERSPROFILE"
    $found = 1
}

Write-Host -ForegroundColor Green "Checking for NVSmart in Registry"
LogWrite "Checking for NVSmart in Registry"

If(Test-Path "HKLM:\Software\Classes\FAST") {
    Write-Host -ForegroundColor Red "NVSmart Found in Registry"
    $found = 1
} 

If($found -eq 0) {
    LogWrite "System $($env:COMPUTERNAME) is clean"
}

If($found -eq 1) {
    LogWrite "***********************************************"
    LogWrite " "
    LogWrite "System $($env:COMPUTERNAME) has been infected!"
    LogWrite " "
    LogWrite "***********************************************"
}

