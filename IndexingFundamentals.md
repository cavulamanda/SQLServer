# Indexing

- Get full detils of the table :

  ```SQL

  EXEC sp_help 'schemaName.TableName'

  ```

- Get Index details using:
  ```SQL
  SELECT * FROM sys.dm_db_index_physical_stats(
  db_id(N'DatabaseName')
  ,object_id(N'schemaName.databaseName')
  , 1 -- for clustered index
  ,NULL
  ,'DETAILED'
  )

  ```
