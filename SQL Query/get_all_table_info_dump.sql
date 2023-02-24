/*
 * Author: Atanu Sarkar
 * Created: 07-09-2021
 * Last Edited: 24-02-2023
 * Last Version: v1.0.1
 *
 * MSSQL Script to get full info dump from database
 * 
 * This script will pull all tables (system tables, user tables and views) 
 * and dump all column names, datatype, constrains and other info in a tabular structure
 * so that you can export and share across in excel
 *
 */


-- Method 1
SELECT 
o.name, c.name 
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id=o.object_id
ORDER BY o.name, c.column_id;

-- Method 2
SELECT 
o.name AS [Table Name], c.name AS [Column / Data Field Names]
FROM sys.columns c
INNER JOIN sys.objects o ON c.object_id=o.object_id
-- optional parameter if you want to filter for specific column
-- WHERE c.name = '<name of the column you want to find>'
ORDER BY o.name, c.name;

-- Method 3
SELECT
sh.name+'.'+o.name AS [Object Name],
o.type_desc AS [Object Type],
o.name AS [Table Name],
s.name AS [Column Name / Data Field Names]
    ,CASE
        WHEN t.name IN ('char','varchar') THEN t.name+'('+CASE WHEN s.max_length<0 THEN 'MAX' ELSE CONVERT(VARCHAR(10),s.max_length) END+')'
        WHEN t.name IN ('nvarchar','nchar') THEN t.name+'('+CASE WHEN s.max_length<0 THEN 'MAX' ELSE CONVERT(VARCHAR(10),s.max_length/2) END+')'
        WHEN t.name IN ('numeric') THEN t.name+'('+CONVERT(VARCHAR(10),s.precision)+','+CONVERT(VARCHAR(10),s.scale)+')'
        ELSE t.name
    END AS DataType

    ,CASE
            WHEN s.is_nullable=1 THEN 'NULL'
        ELSE 'NOT NULL'
    END AS Nullable
    ,CASE
            WHEN ic.column_id IS NULL THEN ''
            ELSE ' identity('+ISNULL(CONVERT(VARCHAR(10),ic.seed_value),'')+','+ISNULL(CONVERT(VARCHAR(10),ic.increment_value),'')+')='+ISNULL(CONVERT(VARCHAR(10),ic.last_value),'null')
        END
    +CASE
            WHEN sc.column_id IS NULL THEN ''
            ELSE ' computed('+ISNULL(sc.definition,'')+')'
        END
    +CASE
            WHEN cc.object_id IS NULL THEN ''
            ELSE ' check('+ISNULL(cc.definition,'')+')'
        END
        AS MiscInfo
FROM sys.columns                           s
    INNER JOIN sys.types                   t ON s.system_type_id=t.user_type_id and t.is_user_defined=0
    INNER JOIN sys.objects                 o ON s.object_id=o.object_id
    INNER JOIN sys.schemas                sh ON o.schema_id=sh.schema_id
    LEFT OUTER JOIN sys.identity_columns  ic ON s.object_id=ic.object_id AND s.column_id=ic.column_id
    LEFT OUTER JOIN sys.computed_columns  sc ON s.object_id=sc.object_id AND s.column_id=sc.column_id
    LEFT OUTER JOIN sys.check_constraints cc ON s.object_id=cc.parent_object_id AND s.column_id=cc.parent_column_id
-- add, modify or remove the where statement below according to the type of tables you want
WHERE o.type_desc IN ('USER_TABLE', 'VIEW')
ORDER BY sh.name+'.'+o.name,s.column_id;
