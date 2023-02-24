/*
 * Author: Atanu Sarkar
 * Created: 20-06-2022
 * Last Edited: 24-02-2023
 * Last Version: v1.0.1
 *
 * DB query about rankedGroupTables and PARTITION
 * 
 * Use Case:
 * Imagine you have two tables: items and item_histories
 * item contains details of items and item_histories contain all transactions with item in real time.
 *
 * now, both the tables contain item_id to identify the items.
 * you want full item details along with a new column containing the latest transaction from item_histories
 * you can't simply use JOIN here, and it's the perfect use-case to use PARTITION and rankedGroupTables
 *
 * Method 1 & 2: are for observation and 
 * Method 3: is final product of the above use-case
 * see below and modify table & column names as per requirement:
 */


-- Method 1: (observe partition and ranked grouped table)
WITH rankedGroupTables AS (
  SELECT mainTable.*, ROW_NUMBER() OVER (PARTITION BY item_id ORDER BY updatedAt DESC) AS rowNumber
  FROM item_histories AS mainTable
)
SELECT item_id, [other_columns_from_histTable], updatedAt FROM rankedGroupTables WHERE rowNumber = 1;


-- Method 2: (observe partition and ranked grouped table)
WITH rankedGroupTables AS (
  SELECT mainTable.*, ROW_NUMBER() OVER (PARTITION BY item_id ORDER BY updatedAt DESC) AS rowNumber
  FROM item_histories AS mainTable
)
SELECT item_id, [other_columns_from_histTable] AS 'column_names', updatedAt FROM rankedGroupTables WHERE rowNumber = 1;


-- Method 3: (data from main item table + latest transaction from item_histories)
WITH item_table AS (
    SELECT * FROM items
    WHERE updatedAt < DATEADD(DAY, -3, GETDATE())
    -- example: if you have status colum, you can throw that in to add more filters:
    AND [item_status] IN ('Shipment Open', 'Shipment In Transit', 'Shipment Delivered')
),
hist_table_with_top_data AS (
    SELECT item_id, [other_columns_from_histTable] AS 'column_names', createdAt AS 'histCreatedAt', updatedAt AS 'histUpdatedAt' FROM (
        SELECT mainTable.*, ROW_NUMBER() OVER (PARTITION BY item_id ORDER BY updatedAt DESC) AS rowNumber
        FROM item_histories AS mainTable
    ) AS resultTable
    WHERE rowNumber = 1
)
SELECT [columns_from_itemTable] AS 'item_column_names', [columns_from_histTable] AS 'hist_column_names'
FROM item_table LEFT JOIN hist_table_with_top_data
ON item_table.item_id = hist_table_with_top_data.item_id

