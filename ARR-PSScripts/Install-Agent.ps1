$hst = $env:COMPUTERNAME
$procs = Get-Process -Name agentName*
$srvcs = Get-Service -Name agentName*
$log = ""
$os = gwmi win32_operatingsystem


if($procs.Count -eq 0 -and $srvcs.Count -eq 0 -and $os.name -notlike "*server*")
{
    msiexec /i /qn c:\temp\agentName.msi
    $timestamp = Get-Date
    $log += "$timestamp`t$hst`tInstalling agentName"+"`n"
}
else
{
    if($srvcs.Status -eq "Stopped")
    {
        Start-Service -Name agentName
        $timestamp = Get-Date
        $log += "$timestamp`t$hst`tStarting agentName service"+"`n"
    }
    $timestamp = Get-Date
    $log += "$timestamp`t$hst`tSkipping agentName install"+"`n"
}
$timestamp = Get-Date
$log += "$timestamp`t$hst`tEnd of script"+"`n"
$log >> "\\shareHost\shareFolder\agentName_log.log"
