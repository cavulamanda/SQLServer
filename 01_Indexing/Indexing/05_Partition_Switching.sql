/*
This script gives example for partition switching

Possible combinations
1: Source - non partitioned to Target - non partitioned THEN Reverse
2: Source - non partitioned to Target - partitioned		THEN Reverse
3: Source - partitioned		to Target - non partitioned	THEN Reverse (Similar to step 2 Revers)
4: Source - partitioned		to Target - partitioned		THEN Reverse

*/

USE chandan;
GO
-- GetNums function
DROP FUNCTION IF EXISTS dbo.GetNums;
GO

CREATE FUNCTION GetNums(@n AS BIGINT) RETURNS TABLE AS RETURN
  WITH
  L0   AS(SELECT 1 AS c UNION ALL SELECT 1),
  L1   AS(SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
  L2   AS(SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
  L3   AS(SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
  L4   AS(SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
  L5   AS(SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
  Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n FROM L5)
  SELECT TOP (@n) n FROM Nums ORDER BY n;
GO

-- create partition function
CREATE PARTITION FUNCTION pfSales (DATE) AS RANGE RIGHT FOR VALUES ('2013-01-01','2014-01-01','2015-01-01');

-- create partition scheme
CREATE PARTITION SCHEME psSales AS PARTITION pfSales ALL TO ([Primary]); -- Adding all partitions to primary file group, this can be chaned later to individual file group


-- Condition 1: Source - non partitioned to Target - non partitioned-------------------------------------------------------------
	-- create source - non partitioned
	DROP TABLE IF ExiSTS SalesSource;
	CREATE TABLE SalesSource(SalesDate Date,Quatity INT) On [PRIMARY];

	-- create target - non partitioned 
	DROP TABLE IF ExiSTS SalesTarget;
	CREATE TABLE SalesTarget(SalesDate Date,Quatity INT) On [PRIMARY];

	-- Insert Into source table
	INSERT INTO SalesSource(SalesDate, Quatity)
	SELECT DATEADD(DAY, dates.n-1,'2012-01-01') as SalesDate, qty.n as Quantity
	FROM GetNums(dateDiff(DD,'2012-01-01', '2013-01-01')) dates
	CROSS JOIN GetNums(1000) as qty

	-- Check Tables Before switch
	SELECT 'Source' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesSource')
	Union ALL
	SELECT 'Target' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesTarget')

	-- Switch To Target
	ALTER TABLE SalesSource SWITCH TO SalesTarget;

	-- Check Tables After switch
	SELECT 'Source' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesSource')
	Union ALL
	SELECT 'Target' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesTarget')

	-- Switch To Source
	ALTER TABLE SalesTarget SWITCH TO SalesSource;
	
	-- Check Tables After switch
	SELECT 'Source' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesSource')
	Union ALL
	SELECT 'Target' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesTarget')
	
	-- Notes : Switing the non partitioned tables will switch whole table to another
-- Condition 1: END--------------------------------------------------------------------------------------------------------------

-- Condition 2: Source - non partitioned to Target - partitioned-----------------------------------------------------------------
	-- create source - non partitioned
	DROP TABLE IF ExiSTS SalesSource;
	CREATE TABLE SalesSource(SalesDate Date,Quatity INT) On [PRIMARY];

	-- create target - partitioned 
	DROP TABLE IF ExiSTS SalesTarget;
	CREATE TABLE SalesTarget(SalesDate Date,Quatity INT) On psSales(SalesDate);

	-- Insert Into source table
	INSERT INTO SalesSource(SalesDate, Quatity)
	SELECT DATEADD(DAY, dates.n-1,'2012-01-01') as SalesDate, qty.n as Quantity
	FROM GetNums(dateDiff(DD,'2012-01-01', '2013-01-01')) dates
	CROSS JOIN GetNums(1000) as qty

	--Switch Fails
	ALTER TABLE SalesSource SWITCH TO SalesTarget PARTITION 1;

	--create a check contraint to source table to ensure that the partition will fit
	ALTER TABLE SalesSource 
	WITH CHECK ADD CONSTRAINT ckMinSalesdate CHECK (SalesDate IS NOT NULL AND SalesDate>='2012-01-01');

	ALTER TABLE SalesSource
	WITH CHECK ADD CONSTRAINT ckMaxSalesDate CHECK (SalesDate IS NOT NULL AND SalesDate<'2013-01-01');

	--Switch To Target
	ALTER TABLE SalesSource SWITCH TO SalesTarget PARTITION 1;

	-- Check Tables After switch
	SELECT 'Source' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesSource')
	Union ALL
	SELECT 'Target' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesTarget')
	
	--Switch To Target Fails
	ALTER TABLE SalesTarget SWITCH Partition 1 TO SalesSource;
	
	--Chage source table contrains
	ALTER TABLE Salessource
	DROP CONSTRAINT ckMinSalesdate;

	ALTER TABLE Salessource
	DROP CONSTRAINT ckMaxSalesdate;

	--Switch To Target
	ALTER TABLE SalesTarget SWITCH Partition 1 TO SalesSource;
	
	-- Check Tables After switch
	SELECT 'Source' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesSource')
	Union ALL
	SELECT 'Target' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesTarget')
	
	-- notes: Check contraints needs to be used when non patitioned and partitioned tables are used

-- Condition 2: END -------------------------------------------------------------------------------------------------------------

-- Condition 3: Source - partitioned to Target - Non partitioned-----------------------------------------------------------------

	--SAME AS Step 2 where data is transfered from Target to source

-- Condition 3: END--------------------------------------------------------------------------------------------------------------

-- Condition 4: Source - partitioned to Target - partitioned---------------------------------------------------------------------
	-- create source - partitioned
	DROP TABLE IF ExiSTS SalesSource;
	CREATE TABLE SalesSource(SalesDate Date,Quatity INT) On psSales(SalesDate);

	-- create target - partitioned 
	DROP TABLE IF ExiSTS SalesTarget;
	CREATE TABLE SalesTarget(SalesDate Date,Quatity INT) On psSales(SalesDate);

	-- Insert Into source table
	INSERT INTO SalesSource(SalesDate, Quatity)
	SELECT DATEADD(DAY, dates.n-1,'2012-01-01') as SalesDate, qty.n as Quantity
	FROM GetNums(dateDiff(DD,'2012-01-01', '2013-01-01')) dates
	CROSS JOIN GetNums(1000) as qty

	-- Check Tables Before switch
	SELECT 'Source' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesSource')
	Union ALL
	SELECT 'Target' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesTarget')

	-- Switch To Target
	ALTER TABLE SalesSource SWITCH Partition 1 TO SalesTarget partition 1;

	-- Check Tables After switch
	SELECT 'Source' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesSource')
	Union ALL
	SELECT 'Target' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesTarget')


	-- Check Tables Before switch
	SELECT 'Source' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesSource')
	Union ALL
	SELECT 'Target' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesTarget')

	-- Switch To Target
	ALTER TABLE SalesTarget SWITCH Partition 1 TO SalesSource partition 1;

	-- Check Tables After switch
	SELECT 'Source' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesSource')
	Union ALL
	SELECT 'Target' as TableType,pstats.partition_number as PartitionNumber,pstats.row_count as PartitionRowCount
	FROM [sys].[dm_db_partition_stats]	pstats
	WHERE pstats.object_id=OBJECT_ID('SalesTarget')


-- Condition 4: END--------------------------------------------------------------------------------------------------------------

-- Columnstore index

Create Clustered ColumnStore index ccix_SalesTarget on SalesTarget

Create Clustered ColumnStore index ccix_SalesSource on SalesSource

CREATE  index nix_Salesdate on SalesTarget(SalesDate) INCLuDE(quatity)

SElECT * FROm SalesSource
SELECT * fROm SalesTarget where SalesDate ='2012-05-21'
CREATE COLUMNSTORE INDEX CSIX
--View partitioned Table information
SELECT
	OBJECT_SCHEMA_NAME(pstats.object_id) AS SchemaName
	,OBJECT_NAME(pstats.object_id) AS TableName
	,ps.name AS PartitionSchemeName
	,ds.name AS PartitionFilegroupName
	,pf.name AS PartitionFunctionName
	,CASE pf.boundary_value_on_right WHEN 0 THEN 'Range Left' ELSE 'Range Right' END AS PartitionFunctionRange
	,CASE pf.boundary_value_on_right WHEN 0 THEN 'Upper Boundary' ELSE 'Lower Boundary' END AS PartitionBoundary
	,prv.value AS PartitionBoundaryValue
	,c.name AS PartitionKey
	,CASE 
		WHEN pf.boundary_value_on_right = 0 
		THEN c.name + ' > ' + CAST(ISNULL(LAG(prv.value) OVER(PARTITION BY pstats.object_id ORDER BY pstats.object_id, pstats.partition_number), 'Infinity') AS VARCHAR(100)) + ' and ' + c.name + ' <= ' + CAST(ISNULL(prv.value, 'Infinity') AS VARCHAR(100)) 
		ELSE c.name + ' >= ' + CAST(ISNULL(prv.value, 'Infinity') AS VARCHAR(100))  + ' and ' + c.name + ' < ' + CAST(ISNULL(LEAD(prv.value) OVER(PARTITION BY pstats.object_id ORDER BY pstats.object_id, pstats.partition_number), 'Infinity') AS VARCHAR(100))
	END AS PartitionRange
	,pstats.partition_number AS PartitionNumber
	,pstats.row_count AS PartitionRowCount
	,p.data_compression_desc AS DataCompression
FROM		[sys].[dm_db_partition_stats] AS pstats
INNER JOIN	[sys].[partitions] AS p ON pstats.partition_id = p.partition_id
INNER JOIN	[sys].[destination_data_spaces] AS dds ON pstats.partition_number = dds.destination_id
INNER JOIN	[sys].[data_spaces] AS ds ON dds.data_space_id = ds.data_space_id
INNER JOIN	[sys].[partition_schemes] AS ps ON dds.partition_scheme_id = ps.data_space_id
INNER JOIN	[sys].[partition_functions] AS pf ON ps.function_id = pf.function_id
INNER JOIN	[sys].[indexes] AS i ON pstats.object_id = i.object_id AND pstats.index_id = i.index_id AND dds.partition_scheme_id = i.data_space_id AND i.type <= 1 /* Heap or Clustered Index */
INNER JOIN	[sys].[index_columns] AS ic ON i.index_id = ic.index_id AND i.object_id = ic.object_id AND ic.partition_ordinal > 0
INNER JOIN	[sys].[columns] AS c ON pstats.object_id = c.object_id AND ic.column_id = c.column_id
LEFT JOIN	[sys].[partition_range_values] AS prv ON pf.function_id = prv.function_id AND pstats.partition_number = (CASE pf.boundary_value_on_right WHEN 0 THEN prv.boundary_id ELSE (prv.boundary_id+1) END)
WHERE pstats.object_id = OBJECT_ID('Sales')
ORDER BY TableName, PartitionNumber;


create column 
