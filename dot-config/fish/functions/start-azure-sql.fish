function start-azure-sql
docker run --cap-add SYS_PTRACE -e 'ACCEPT_EULA=1' -e 'MSSQL_SA_PASSWORD=yourStrong(!)Password' -p 1433:1433 --platform=linux/amd64 --name azuresqledge -d mcr.microsoft.com/azure-sql-edge
end
