# SQLServer
Contains SQL Server Items

#Links to download the sample files for 
#SSAS:
https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks-analysis-services


https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks


### GET List of dependecies in a Proc

```sql
DECLARE @procName VARCHAR(100)
SET @procName = 'myProcName'

SELECT DISTINCT
Schema_Name = schema_name(obj.Schema_id)
,Proc_Name = obj.Name
,Referenced_ObjectSchema = schema_name(dep_obj.schema_id)
,Referenced_ObjectName = dep_obj.Name
,ObjectTpe = dep_obj.Type_desc

FROM sys.objects obj
LEFT JOIN sys.sql_expression_dependencies dep on dep.referencing_id=obj.object_id
LEFT JOIN sys.objects dep_obj on dep_obj.object_id = dep.referenced_id

WHERE
obj.type in ('P','X','PC','RF')
and obj.Name= @procName
Order by
1,2,5,4

```
