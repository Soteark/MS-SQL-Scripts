with FailedExecs
          as
          (
                   select Distinct
                         --comment out    s.executionid
                   from dbo.sysssislog_Singapore  s
                   where event='OnError'
          ),

          FirstPackage
          as
          (       
                   select
                     ROW_NUMBER() over ( partition by s.sourceid
                     order by min(s.Starttime) ) Batchid
                    ,min(s.Starttime) as  StartTime
                    ,cast(convert(char(8),min(s.Starttime) ,112) as int) as StartDatekey
                   ,s.executionid
                   ,s.source
                 from dbo.sysssislog_Singapore s
                 where s.source like 'First Package Name'
                   and event not like ('User:%')
                   and s.executionid not in (select executionid from FailedExecs)
                group by s.executionid ,s.source,s.sourceid
          ),

          LastPackage
          as
          (
          select
                      ROW_NUMBER() over ( partition by s.source
                      order by max(s.Endtime) ) Batchid
                    ,max(s.Endtime) as EndTime
                    ,cast(convert(char(8),min(s.Endtime) ,112) as int) as EndDatekey
                   ,s.executionid
                   ,s.source
          from dbo.sysssislog_Singapore s
          where s.source like 'Last Package Name'
          and event not like ('User:%') --Note
          and s.executionid not in (select executionid from FailedExecs)
          group by s.executionid ,s.source,s.sourceid
          ) 

-- insert into aud.ETLPhaseBatches 

          select Distinct
                   N'Staging' as [ETLPhase]
                   ,N'Singapore'  as [SourceSystem]
                   ,f.Batchid as BatchId
                   ,f.StartTime as StartTime
                   ,f.StartDatekey as StartDatekey
                   ,l.EndTime         as        EndTime 
                   ,l.EndDatekey      as EndDatekey
                  --,d.DayNumberDesc
                   --,d.WeekNumberDesc
                   --,d.MonthNumberDesc
                   -- ,d.YearNumberDesc       
                   ,datediff (second,f.StartTime,l.EndTime ) as EstBatchExecTime_Sec
                   ,datediff (MINUTE,f.StartTime,l.EndTime ) as EstBatchExecTime_Min
          from FirstPackage f
          inner join LastPackage l
          on f.Batchid=l.Batchid 
          --inner join [Dim].[Date] d
          --on d.DateISOName=f.StartDatekey
