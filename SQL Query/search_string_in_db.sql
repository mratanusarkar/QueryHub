/*
 * Author: Atanu Sarkar
 * Created: 14-12-2022
 * Last Edited: 24-02-2023
 * Last Version: v1.0.1
 *
 * MSSQL Script to search & scan a string or word in full database
 * 
 * This script scan through all tables in a database
 * and pick out all columns and cells that contains the @SearchStr
 * you will be able to detect the table name and column name and row where the string was found
 * and do what you wish to do with that info.
 *
 */


DECLARE @SearchStr NVARCHAR(255)
SET @SearchStr = '<ENTER THE STRING YOU WANT TO SEARCH>'

CREATE TABLE #Results (ColumnName NVARCHAR(370), ColumnValue NVARCHAR(3630))

SET NOCOUNT ON

DECLARE @TableName NVARCHAR(256), @ColumnName NVARCHAR(128), @SearchStrQuery NVARCHAR(110)
SET  @TableName = ''
SET @SearchStrQuery = QUOTENAME('%' + @SearchStr + '%','''')

WHILE @TableName IS NOT NULL
BEGIN
    SET @ColumnName = ''
    SET @TableName = 
    (
        SELECT MIN(QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME))
        FROM   INFORMATION_SCHEMA.TABLES
        WHERE  TABLE_TYPE = 'BASE TABLE'
            AND    QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME) > @TableName
            AND    OBJECTPROPERTY(
                OBJECT_ID(
                    QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)
                ), 'IsMSShipped'
            ) = 0
    )

    WHILE (@TableName IS NOT NULL) AND (@ColumnName IS NOT NULL)
    BEGIN
        SET @ColumnName =
        (
            SELECT MIN(QUOTENAME(COLUMN_NAME))
            FROM     INFORMATION_SCHEMA.COLUMNS
            WHERE         TABLE_SCHEMA    = PARSENAME(@TableName, 2)
                AND    TABLE_NAME    = PARSENAME(@TableName, 1)
                AND    DATA_TYPE IN ('char', 'varchar', 'nchar', 'NVARCHAR', 'int', 'decimal')
                AND    QUOTENAME(COLUMN_NAME) > @ColumnName
        )
    
        IF @ColumnName IS NOT NULL
        BEGIN
            INSERT INTO #Results
            EXEC
            (
                'SELECT ''' + @TableName + '.' + @ColumnName + ''', LEFT(' + @ColumnName + ', 3630) FROM ' + @TableName + ' (NOLOCK) ' +
                ' WHERE ' + @ColumnName + ' LIKE ' + @SearchStrQuery
            )
        END
    END   
END

-- Select the output of your choice. In case of too many duplicates, go with DISTINCT
-- SELECT * FROM #Results
SELECT DISTINCT * FROM #Results
 
DROP TABLE #Results
