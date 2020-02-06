$container = "sql2019rc3";
$port = '1437:1433'
$instance = "localhost,1433";
$database = "WideWorldImporters";
$dockerlogin = "dockerlogin";

docker run -v d:/backup:/backup -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=P@ssw0rd1" -p $port --name $container -d mcr.microsoft.com/mssql/server:2019-latest #;