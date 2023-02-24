/*
 * Author: Atanu Sarkar
 * Created: 29-06-2022
 * Last Edited: 24-02-2023
 * Last Version: v1.0.1
 *
 * MSSQL Script to get a table info dump from database
 * 
 * This script will dump column id, names, datatype, and other info of a database table
 * so that you can export and share across in excel
 *
 */


DECLARE @TableName NVARCHAR(255);
SET @TableName = '<NAME OF THE TABLE YOU WANT>'

SELECT schema_name(tab.schema_id) AS schema_name,
    tab.name AS table_name, 
    col.column_id,
    col.name AS column_name, 
    t.name AS data_type,    
    col.max_length,
    col.precisiON
FROM sys.tables AS tab
    INNER JOIN sys.columns AS col
        ON tab.object_id = col.object_id
    LEFT JOIN sys.types AS t
    ON col.user_type_id = t.user_type_id
where tab.name = @TableName
ORDER BY schema_name,
    table_name, 
    column_id;
