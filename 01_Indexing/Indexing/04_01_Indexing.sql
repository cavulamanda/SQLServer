-- This script demonstrats Index fundamentals
--Pluralsight course: https://app.pluralsight.com/library/courses/sql-server-indexing/table-of-contents

use tempdb;
go

DROP TABLE IF EXISTS Indexing
CREATE TABLE Indexing(
ID INT Identity(1,1)
,[Name] CHAR(4000)
,Company CHAR(4000)
,Pay Int)


--GET Index Definition
SELECT
object_name(object_id) TableName
, ISNULL(name,object_name(object_id)) IndexName
, Index_Id
, type_desc
FROM [sys].[indexes] 
WHERE object_name(object_id) = 'Indexing' --table name created above

--Insert values to the new table
SET NOCOUNT ON

INSERT INTO Indexing VALUEs ('TestUser','ExtremeExperts',10000)

--Check Status

SELECT
Object_name(object_id) [Name]
, index_type_desc as Index_Type
, alloc_unit_type_desc as Data_Type
, index_id as Index_id
, index_depth as Depth
, index_level as Ind_level
, record_count as RecordCount
, page_count as [PageCount]
, fragment_count as Fragmentation

FROM [sys].[dm_db_index_physical_stats](db_id(),object_id('Indexing'),null,null,null)

--insert some more values
INSERT INTO Indexing 
values('Steve','Central',15000)
,('Pinal','SQLAuthority',13000)

--INSERT 100 rows
INSERT INTO Indexing Values
('Dummy','JunkCOmpany',1000)
GO 100
;

--Create clustered index

Create Clustered Index CI_IndexingId on Indexing(ID)
GO

SELECT
Object_name(object_id) [Name]
, index_type_desc as Index_Type
, alloc_unit_type_desc as Data_Type
, index_id as Index_id
, index_depth as Depth
, index_level as Ind_level
, record_count as RecordCount
, page_count as [PageCount]
, fragment_count as Fragmentation

FROM [sys].[dm_db_index_physical_stats](db_id(),object_id('Indexing'),null,null,null)


--INSERT 700 rows
INSERT INTO Indexing Values
('MoreJunk','MoreJunkCOmpany',100)
GO 7000

--CHECK statistics
DBCC SHOW_Statistics ('Indexing',CI_IndexingId)
update statistics Indexing -- previousl only 103 records were showing as 7000 rows were added after index creation, after update statistics correct number of rows are given

-- create non-clustered index
Create nonclustered index NCI_Pay on Indexing(Pay)
GO

--CHECK statistics
DBCC SHOW_Statistics ('Indexing',NCI_Pay)