--Test Line Addtion
DECLARE @tNumTbl TABLE ( Number INT );


-- CTE Start Comments
WITH
	CTE_Numbers ( Number ) AS (
		SELECT 0 [Number]
		UNION ALL
		SELECT CN.Number + 1
		FROM CTE_Numbers CN
		WHERE CN.Number <= 3649)

INSERT INTO @tNumTbl ( Number )
SELECT CN.Number
FROM CTE_Numbers CN
OPTION ( MAXRECURSION 4000 );

DECLARE
	@dStartDt DATE = DATEADD(YEAR,-5,GETDATE())
	,@dEndDt DATE = GETDATE()

SELECT DATEADD(DAY,Number+1,@dStartDt) [Date]
FROM @tNumTbl TNT
WHERE DATEADD(DAY,Number+1,@dStartDt) <= @dEndDt
