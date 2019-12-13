/*
study material from : https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0

*/

/*
--Enable and Clear the query store in master
ALTER DATABASE WideWorldImporters SET Query_Store = ON;
ALTER DATABASE WideWorldImporters SET Query_Store CLEAR; 
GO


-- create few store procs

Use WideWorldImporters
GO

CREATE PROC sales. ups_CustomerTranscationInfo (@Customer Int)
AS
SELECT CustomerID, SUM(AmountExcludingTax) as NetAmount
FROM sales.CustomerTransactions
--WHERE CustomerID = @Customer
GROUP BY CustomerID;
GO

CREATE PROC [Application].[usp_GetPersonInfo] (@PersonID Int)
AS
SELECT 
p.FullName
,p.EmailAddress
,c.FormalName
FROM [Application].[People] p
LEFT OUTER JOIN [Application].[Countries] c on p.PersonID=c.LastEditedBy
WHERE p.PersonID= @PersonID;
GO

exec sales. ups_CustomerTranscationInfo 925
exec sales. ups_CustomerTranscationInfo 1042
exec sales. ups_CustomerTranscationInfo 1011
exec sales. ups_CustomerTranscationInfo 401


*/

--query store query

SELECT
qsq.query_id
,qsp.plan_id
,qsq.[object_id]
,rs.count_executions
,qsp.last_execution_time
,[LocalLastExecutionTime] = DateAdd(minute,-(datediff(minute, getdate(),getutcdate())),qsp.last_execution_time)
, qst.query_sql_text
,ConvertedPlan = Try_Convert(XML,  qsp.query_plan)
FROM [sys]. [query_store_query] qsq
INNER JOIN [sys].[query_store_query_text] qst on qsq.query_text_id=qst.query_text_id
INNER JOIN [sys].[query_store_plan] qsp on  qsq.query_id=qsp.query_id
INNER JOIN [sys].[query_store_runtime_stats] rs on qsp.plan_id=rs.plan_id

WHERE qsq.[object_id] = OBJECT_ID('sales.ups_CustomerTranscationInfo')

GO


