BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED ;

WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
q_dataset AS (
        SELECT
                t2.query_plan [QueryPlan]
                ,t1.plan_handle [PlanHandle]
                ,t3.[Text] [Statement]
                ,n.value('(@StatementOptmLevel)[1]', 'VARCHAR(25)') [OptimizationLevel]
                ,ISNULL(CAST(n.value('(@StatementSubTreeCost)[1]', 'VARCHAR(128)') as float),0) [SubTreeCost]
                ,t1.usecounts [UseCounts]
                ,t1.size_in_bytes [SizeInBytes]
        FROM
                sys.dm_exec_cached_plans t1
                CROSS APPLY sys.dm_exec_query_plan(t1.plan_handle) t2
                CROSS APPLY sys.dm_exec_sql_text(t1.plan_handle) t3
                CROSS APPLY query_plan.nodes ('/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple') qn ( n ))

SELECT
        TOP 100
        t1.QueryPlan
        ,t1.PlanHandle
        ,t1.[Statement]
        ,t1.OptimizationLevel
        ,t1.SubTreeCost
        ,t1.usecounts
        ,t1.SubTreeCost * t1.UseCounts [GrossCost]
        ,t1.SizeInBytes
FROM q_dataset t1
where t1.[Statement] like '%%'
ORDER BY GrossCost DESC
END

added a new line for release