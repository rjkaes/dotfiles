function azure-edge
docker exec -i azuresqledge /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'yourStrong(!)Password' $argv
end
