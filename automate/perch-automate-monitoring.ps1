#Requires -RunAsAdministrator
$BinDestination = "C:\Program Files\Elastic\Beats\7.15.5\metricbeat"
$Destination = "C:\ProgramData\Elastic\Beats\metricbeat"
$WebClient = New-Object System.Net.WebClient
$baseRepoURL = "https://raw.githubusercontent.com/PerchSecurity/metricbeat-config/master/automate"
$keystoreCMD = "& `"$BinDestination\metricbeat.exe`" --path.home '$BinDestination' --path.config '$BinDestination' --path.data '$Destination\data' --path.logs '$Destination\logs'"

Write-Output "STOP! You will need to create a read only database user for the LabTech/Automate DB"
Write-Output "Instructions at https://perch.help/integrations/connectwise-automate-advanced-monitoring/"
Read-Host "Press Enter to continue..."

##Download Metricbeat
Write-Output "Downloading Metricbeat 7.15.5 MSI"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.17.5-windows-x86_64.msi" -OutFile "$env:TEMP\metricbeat-7.15.5-windows-x86_64.msi"
                        
##Install Metricbeat
Write-Output "Installing Metricbeat 7.15.5"
Write-Output "Press a key when Metricbeat install is finished"
Start-Process "$env:TEMP\.\metricbeat-7.15.5-windows-x86_64.msi" -wait
Write-Output "Press a key when Metricbeat install is finished"
Stop-Service metricbeat
Write-Output "Downloading Config Files"
#Rename-Item "$BinDestination\metricbeat.yml" -Destination "$BinDestination\metricbeat.yml.bak.perch" -Force
Start-Sleep -s 2
Invoke-WebRequest -Uri "$baseRepoURL/metricbeat-generic.yml" -Outfile "$BinDestination\metricbeat.yml"
Invoke-WebRequest -Uri "$baseRepoURL/metricbeat.yml" -Outfile "$Destination\metricbeat.yml"
Start-Sleep -s 2
##Configure Metricbeat keystore
Set-Location "$BinDestination"
Invoke-Expression "$keystoreCMD keystore create"
Write-Output "Input the read only sql user - example perch-readonly"
Invoke-Expression "$keystoreCMD keystore add perch-read-only-sql-user"
Write-Output "Input the read only sql user password - This should be complex and random"
Invoke-Expression "$keystoreCMD  keystore add perch-read-only-sql-pass"
Write-Output "Input the IP address of your SQL server - use 127.0.0.1 if this is the SQL server"
Invoke-Expression "$keystoreCMD  keystore add sql-server-ip"
Write-Output "Input the port of your SQL server - use 3306 if it is a default MySQL setup"
Invoke-Expression "$keystoreCMD  keystore add sql-server-port"
Write-Output "Input the database name - use labtech if this is a default setup"
Invoke-Expression "$keystoreCMD  keystore add sql-server-db"
Write-Output "Input the Perch Client Token - This is available at https://app.perchsecurity.com/settings/sensors"
Invoke-Expression "$keystoreCMD  keystore add perch-client-token"
Write-Output "Stopping Metricbeat Service"
Stop-Service metricbeat
Write-Output "Downloading Config Files"
Start-Sleep -s 5

Invoke-WebRequest -Uri "$baseRepoURL/metricbeat.yml" -Outfile "$Destination\metricbeat.yml"
Invoke-WebRequest -Uri "$baseRepoURL/modules.d/auto-actions.yml" -Outfile "$Destination\modules.d\auto-actions.yml"
Invoke-WebRequest -Uri "$baseRepoURL/modules.d/auto-auth.yml" -Outfile "$Destination\modules.d\auto-auth.yml"
Invoke-WebRequest -Uri "$baseRepoURL/modules.d/auto-commands.yml" -Outfile "$Destination\modules.d\auto-commands.yml"
Invoke-WebRequest -Uri "$baseRepoURL/modules.d/auto-computers.yml" -Outfile "$Destination\modules.d\auto-computers.yml"
Invoke-WebRequest -Uri "$baseRepoURL/modules.d/auto-mfa.yml" -Outfile "$Destination\modules.d\auto-mfa.yml"
Invoke-WebRequest -Uri "$baseRepoURL/modules.d/auto-services.yml" -Outfile "$Destination\modules.d\auto-services.yml"
Invoke-WebRequest -Uri "$baseRepoURL/modules.d/auto-software.yml" -Outfile "$Destination\modules.d\auto-software.yml"
Invoke-WebRequest -Uri "$baseRepoURL/modules.d/auto-startup.yml" -Outfile "$Destination\modules.d\auto-startup.yml"
Invoke-WebRequest -Uri "$baseRepoURL/modules.d/auto-users.yml" -Outfile "$Destination\modules.d\auto-users.yml"
Start-Sleep -s 2


Write-Output "Starting Metricbeat Service"
Start-Service metricbeat






