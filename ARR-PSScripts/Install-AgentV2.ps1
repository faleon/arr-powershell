$logName = 'log.csv'
$logEntries = @()

$username = 'username'
$pw = 'password'
foreach($target in (Get-Content .\targets.txt))
{
    $logEntry = New-Object -TypeName PSObject
    $logEntry | Add-Member -MemberType NoteProperty -Name 'Timestamp' -Value (Get-Date -Format G)
    $logEntry | Add-Member -MemberType NoteProperty -Name 'Host' -Value $target
    $logEntry | Add-Member -MemberType NoteProperty -Name 'CanConnectTo' -Value $true
    $logEntry | Add-Member -MemberType NoteProperty -Name 'TempDir' -Value $null
    $logEntry | Add-Member -MemberType NoteProperty -Name 'CopiedInstallConfig' -Value $false
    $logEntry | Add-Member -MemberType NoteProperty -Name 'CopiedInstaller' -Value $false
    $logEntry | Add-Member -MemberType NoteProperty -Name 'CopiedCmd' -Value $false
    $logEntry | Add-Member -MemberType NoteProperty -Name 'RanAgentInstall' -Value $false
    
    $tempDir = "\\$target\c$\temp"
    
	if((Test-Path \\$target\c$) -ne $true)
    {
        $logEntry.CanConnectTo = $false
    }
    else
    {
        New-Item -Path $tempDir -ItemType "directory" -Force | Out-Null
        $logEntry.TempDir = $tempDir
        
        Copy-Item  -Path .\agent_config.json -Destination $tempDir -Force
        $logEntry.CopiedInstallConfig = [System.IO.File]::Exists("$tempDir\agent_config.json")
        
        Copy-Item  -Path .\agent.msi -Destination $tempDir -Force
        $logEntry.CopiedInstaller = [System.IO.File]::Exists("$tempDir\agent.msi")

        Copy-Item  -Path .\installAgent.cmd -Destination $tempDir -Force
        $cmd = "$tempDir\installAgent.cmd"
        $logEntry.CopiedCmd = (Get-ChildItem -Path $tempDir -Name installAgent.cmd).Name
        
        $logEntry.RanAgentInstall = (Start-Job -ScriptBlock {param($t,$u,$p,$c) \\c$\temp\PsExec.exe \\$t -u $u -p $p $c 2>>pserr.log} -ArgumentList $target,$username,$pw,$cmd).Id
	}
    
    $logEntries += $logEntry
}
$logEntries | select * | Format-Table
$logEntries | Export-Csv $logName -NoTypeInformation -Append

.\Check-Agents.ps1