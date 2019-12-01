-----------------------------------------------
-- Employee Case Study Sample Database Setup
-- Download location : http://bit.ly/2r6BR1g
-- Pluralsight link : https://app.pluralsight.com/library/courses/sqlserver-indexing-for-performance/table-of-contents
-----------------------------------------------
USE [master];
GO

RESTORE DATABASE [EmployeeCaseStudy]
FROM DISK = N'D:\Chandan\Study\SQL_Server\00_SampleDatabase\employeecasestudysampledb2012\EmployeeCaseStudySampleDB2012.bak'
WITH MOVE N'EmployeeCaseStudyData'	TO N'D:\Chandan\Study\SQL_Server\00_SampleDatabase\mployeeCaseStudySampleDB2012.mdf',
	MOVE N'EmployeeCaseStudyLog'	TO N'D:\Chandan\Study\SQL_Server\00_SampleDatabase\mployeeCaseStudySampleDB2012.ldf',
	STATS=10,REPLACE;
GO

--SET The database compatibilty mode to 120-----------
ALTER DATABASE [EmployeeCaseStudy]
SET COMPATIBILITY_LEVEL =120; --SQL SERVER 204
GO
------------------------------------------------------
USE [EmployeeCaseStudy];
GO

--What tables exits?
SELECT t.*
FROM [sys].[tables] t;
GO

--Review table definition and indexes
EXEC [sp_help] 'dbo.Employee'

SET STATISTICS IO ON;
GO

--ENABLE Actual Execution plan
-- Scan
SELECT  * FROM dbo.Employee where LastName like N'%e%';
GO

-- Still a Scan, why? Data is not ordered by LastName, it is by EmployeeID that is why Scan
SELECT * FROM dbo.Employee where LastName like N'E%';
GO

-- Still a Scan
SELECT * FROM dbo.Employee where LastName = N'Eaton';
GO

--BOOKMARK LOOKUP : Only happens to non CLIX---It is Bad for large tables---------------------------------------------------
--CLIX- All the data is in the index so always seek
SELECT ssn					FROM dbo.Employee where EmployeeID=12345;
SELECT EmployeeID,ssn		FROM dbo.Employee where EmployeeID=12345;
SELECT EmployeeID,ssn,Phone	FROM dbo.Employee where EmployeeID=12345;
SELECT *					FROM dbo.Employee where EmployeeID=12345;

--non clusterd index- not all the data is in the index
SELECT EmployeeId			FROM dbo.Employee where ssn='749-21-9445'; --scan, Selective, covered by Non Clustered Index
SELECT EmployeeId,SSN		FROM dbo.Employee where ssn='749-21-9445'; --scan, Selection, covered by Non Clustered Index
SELECT EmployeeId,SSN,Phone FROM dbo.Employee where ssn='749-21-9445'; --Bookmark lookup, Non Selective (Key lookup)
SELECT *					FROM dbo.Employee where ssn='749-21-9445'; --Bookmark lookup, Non Selective (Key lookup)

--heap table, with Non Clustered index on SSN
SELECT EmployeeId			FROM dbo.EmployeeHeap where ssn='749-21-9445'; --Bookmark lookup called RID Looup (Row ID lookup)
SELECT EmployeeId,SSN		FROM dbo.EmployeeHeap where ssn='749-21-9445'; --Bookmark lookup called RID Looup (Row ID lookup)
SELECT EmployeeId,SSN,Phone FROM dbo.EmployeeHeap where ssn='749-21-9445'; --Bookmark lookup called RID Looup (Row ID lookup)
SELECT *					FROM dbo.EmployeeHeap where ssn='749-21-9445'; --Bookmark lookup called RID Looup (Row ID lookup)
------------------------------------------------------------------------------------------------------------------------------

--Clustered index Key
--GET INDEX Physical Stats

SELECT
index_depth as D
,Index_Level as L
,record_count as [Rows]
,page_count as Pages
,avg_page_space_used_in_percent as Page_PercentFull
,min_record_size_in_bytes
,max_record_size_in_bytes
,avg_record_size_in_bytes
--,avg_fragmentation_in_percent
FROM [sys].[dm_db_index_physical_stats](db_id(N'EmployeeCaseStudy'),Object_ID(N'dbo.Employee'),1,NULL,'DETAILED')

/*
The Non clustered Lead level contains:
leaf-level row = nonclustered index column(s) + data row lookup id + row overhead
data row lookup id = fixed RID (if heap) or clustering key (if table has Clustered Index)
*/

--Better code for sp_helpIndex, written by SQLSkills.com
-- Download location : http://bit.ly/2sIyRW4