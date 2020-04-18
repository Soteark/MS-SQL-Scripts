SELECT count(1)/128 AS cached_MB 
    , name 
    , index_id 
FROM sys.dm_os_buffer_descriptors AS bd with (NOLOCK) 
    INNER JOIN 
    (
        SELECT name = OBJECT_SCHEMA_NAME(object_id) + '.' + object_name(object_id)
            --name = 'dbo.' + cast(object_id as varchar(100))
            , index_id 
            , allocation_unit_id
        FROM sys.allocation_units AS au with (NOLOCK)
            INNER JOIN sys.partitions AS p with (NOLOCK) 
                ON au.container_id = p.hobt_id 
                    AND (au.type = 1 OR au.type = 3)
        UNION ALL
        SELECT name = OBJECT_SCHEMA_NAME(object_id) + '.' + object_name(object_id) 
            --name = 'dbo.' + cast(object_id as varchar(100))   
            , index_id
            , allocation_unit_id
        FROM sys.allocation_units AS au with (NOLOCK)
            INNER JOIN sys.partitions AS p with (NOLOCK)
                ON au.container_id = p.partition_id 
                    AND au.type = 2
    ) AS obj 
        ON bd.allocation_unit_id = obj.allocation_unit_id
WHERE database_id = db_id()
GROUP BY name, index_id 
HAVING Count(*) > 128
ORDER BY 1 DESC;

whats in the cache????