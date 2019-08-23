$container = "sql2019rc2";
$port = 1435
$instance = "localhost,1433";
$database = "WideWorldImporters";
$dockerlogin = "dockerlogin";

$containerexists = docker ps -f "name=$container" --format "{{.Names}}";

$containerexists;

if($container -ne $containerexists)
{
    Write-Host "$container does not exist" -ForegroundColor Cyan;

    docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=P@ssw0rd1" -p $port`:1433 --name $container -d mcr.microsoft.com/mssql/server:2019-latest;

    $cred = Get-Credential;

    $agentquery = @"
EXEC sp_configure 'Show Advanced Options',1;
RECONFIGURE;
EXEC sp_configure 'Agent XPs', 1;
RECONFIGURE;
EXEC sp_configure 'Show Advanced Options',0;
RECONFIGURE;
"@;

    Invoke-DbaQuery -SqlInstance $instance -SqlCredential $cred -Database master -Query $agentquery;

    Invoke-DbaQuery -SqlInstance $instance -SqlCredential $cred -Database master -Query "SELECT @@VERSION";

    $exists = Get-DbaLogin -SqlInstance $instance -SqlCredential $cred -Login $dockerlogin;
    if(!$exists)
    {
        $securePassword = Read-Host "Input password" -AsSecureString
        New-DbaLogin -SqlInstance $instance -SqlCredential $cred -Login $dockerlogin -SecurePassword $securePassword -PasswordPolicyEnforced;
        Set-DbaLogin -SqlInstance $instance -SqlCredential $cred -Login $dockerlogin -AddRole sysadmin;
    }
}

docker exec -it sql2019rc mkdir -p /var/opt/mssql/backup
 
docker cp "C:\backup\WideWorldImporters\WideWorldImporters-Full.bak" sql2019rc:/var/opt/mssql/backup

$dockercred = Get-Credential;

$filestructure = @{
'WWI_Primary' = "/var/opt/mssql/data/$database.mdf"
'WWI_UserData' = "/var/opt/mssql/data/$database`_UserData.ndf"
'WWI_Log' = "/var/opt/mssql/data/$database.ldf"
}
#/var/opt/mssql/data/WWI.mdf
#/var/opt/mssql/data/WWI.ldf
#/var/opt/mssql/data/WWI.ndf

Restore-DbaDatabase -SqlInstance $instance -DatabaseName $database -SqlCredential $dockercred -Path "/var/opt/mssql/backup/WideWorldImporters-Full.bak" -FileMapping $filestructure -WithReplace;

