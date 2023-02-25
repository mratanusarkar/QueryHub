SELECT DB_NAME(dbid) as DBName, COUNT(dbid) as NumberOfConnections, loginam as LoginName, sum(cpu) CPU, hostname 
FROM sys.sysprocessesWHEREdbid > 0
--and login_time > '2022-08-23' and login_time < '2022-08-24'GROUP BYdbid, loginame,hostname;