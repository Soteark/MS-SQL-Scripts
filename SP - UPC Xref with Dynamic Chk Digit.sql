create procedure usp_UPCtoItem @TblName nvarchar(max), @ColName nvarchar(max), @PrimaryFlag char(1) = null, @SvdTbl nvarchar(max) = NULL
AS

declare
	@Sql nvarchar(max)
	,@Sql2 nvarchar(max);

--LOAD UPCS
if object_id('tempdb..#tmp_data1') is not null
	drop table #tmp_data1

create table #tmp_data1 ( UPC varchar(50));

set @Sql = N'
insert into #tmp_data1 (UPC)
select distinct cast(cast(cast(t1.'+@ColName+' as varchar(50)) as bigint) as varchar(50)) [UPC]
from '+@TblName+' t1
where t1.'+@ColName+' is not null'

exec sp_executesql @Sql;

if object_id('tempdb..#tmp_data_output') is not null
	drop table #tmp_data_output;

with
	q_baseData as (
		select
			t1.UPC
			,cast(substring(reverse(substring(replicate('0',13-len(t1.UPC))+t1.UPC,1,12)),1,1) as int) [dig1]
			,cast(substring(reverse(substring(replicate('0',13-len(t1.UPC))+t1.UPC,1,12)),2,1) as int) [dig2]
			,cast(substring(reverse(substring(replicate('0',13-len(t1.UPC))+t1.UPC,1,12)),3,1) as int) [dig3]
			,cast(substring(reverse(substring(replicate('0',13-len(t1.UPC))+t1.UPC,1,12)),4,1) as int) [dig4]
			,cast(substring(reverse(substring(replicate('0',13-len(t1.UPC))+t1.UPC,1,12)),5,1) as int) [dig5]
			,cast(substring(reverse(substring(replicate('0',13-len(t1.UPC))+t1.UPC,1,12)),6,1) as int) [dig6]
			,cast(substring(reverse(substring(replicate('0',13-len(t1.UPC))+t1.UPC,1,12)),7,1) as int) [dig7]
			,cast(substring(reverse(substring(replicate('0',13-len(t1.UPC))+t1.UPC,1,12)),8,1) as int) [dig8]
			,cast(substring(reverse(substring(replicate('0',13-len(t1.UPC))+t1.UPC,1,12)),9,1) as int) [dig9]
			,cast(substring(reverse(substring(replicate('0',13-len(t1.UPC))+t1.UPC,1,12)),10,1) as int) [dig10]
			,cast(substring(reverse(substring(replicate('0',13-len(t1.UPC))+t1.UPC,1,12)),11,1) as int) [dig11]
			,cast(substring(reverse(substring(replicate('0',13-len(t1.UPC))+t1.UPC,1,12)),12,1) as int) [dig12]
		from #tmp_data1 t1)
	,q_newUPCs as (
		select
			replicate('0',13-len(UPC))+UPC [org_upc]
			,substring(replicate('0',13-len(UPC))+UPC,1,12)+cast(cast(
				(
					ceiling((cast(((dig1+dig3+dig5+dig7+dig9+dig11)*3) as decimal(18,2))+cast((dig2+dig4+dig6+dig8+dig10+dig12) as decimal(18,2))) / 10) 
					-
					(cast(((dig1+dig3+dig5+dig7+dig9+dig11)*3) as decimal(18,2))+cast((dig2+dig4+dig6+dig8+dig10+dig12) as decimal(18,2))) / 10
				)* 10 as int) as varchar(1)) [new_upc]
		from q_baseData t1)
	,q_assessment as (
		select
			count(*) [total]
			,count(case when org_upc <> new_upc then 1 end) [needs_chkdigit]
			,count(case when org_upc = new_upc then 1 end) [has_chkdigit]
			,case
				when count(case when org_upc <> new_upc then 1 end) > count(case when org_upc = new_upc then 1 end) then 1
				when count(case when org_upc = new_upc then 1 end) >= count(case when org_upc <> new_upc then 1 end) then 0
			end [Create_ChkDigit]
		from q_newUPCs t1)
	,q_CreateUPCs as (
		select
			UPC [org_upc]
			,replicate('0',12-len(UPC))+UPC+cast(cast(
				(
					ceiling((cast(((dig1+dig3+dig5+dig7+dig9+dig11)*3) as decimal(18,2))+cast((dig2+dig4+dig6+dig8+dig10+dig12) as decimal(18,2))) / 10) 
					-
					(cast(((dig1+dig3+dig5+dig7+dig9+dig11)*3) as decimal(18,2))+cast((dig2+dig4+dig6+dig8+dig10+dig12) as decimal(18,2))) / 10
				)* 10 as int) as varchar(1)) [new_upc]
		from (
			select
				UPC
				,cast(substring(reverse(substring(replicate('0',12-len(UPC))+UPC,1,12)),1,1) as int) [dig1]
				,cast(substring(reverse(substring(replicate('0',12-len(UPC))+UPC,1,12)),2,1) as int) [dig2]
				,cast(substring(reverse(substring(replicate('0',12-len(UPC))+UPC,1,12)),3,1) as int) [dig3]
				,cast(substring(reverse(substring(replicate('0',12-len(UPC))+UPC,1,12)),4,1) as int) [dig4]
				,cast(substring(reverse(substring(replicate('0',12-len(UPC))+UPC,1,12)),5,1) as int) [dig5]
				,cast(substring(reverse(substring(replicate('0',12-len(UPC))+UPC,1,12)),6,1) as int) [dig6]
				,cast(substring(reverse(substring(replicate('0',12-len(UPC))+UPC,1,12)),7,1) as int) [dig7]
				,cast(substring(reverse(substring(replicate('0',12-len(UPC))+UPC,1,12)),8,1) as int) [dig8]
				,cast(substring(reverse(substring(replicate('0',12-len(UPC))+UPC,1,12)),9,1) as int) [dig9]
				,cast(substring(reverse(substring(replicate('0',12-len(UPC))+UPC,1,12)),10,1) as int) [dig10]
				,cast(substring(reverse(substring(replicate('0',12-len(UPC))+UPC,1,12)),11,1) as int) [dig11]
				,cast(substring(reverse(substring(replicate('0',12-len(UPC))+UPC,1,12)),12,1) as int) [dig12]
			from #tmp_data1
			) data)
	,q_UPCUsage as (
		select
			case
				when t2.Create_ChkDigit = 1 then replicate('0',13-len(t1.new_upc))+t1.new_upc
				when t2.Create_ChkDigit = 0 then replicate('0',13-len(t1.org_upc))+t1.org_upc
			end [UPC]
		from
			q_CreateUPCs t1
			cross apply q_assessment t2)

select
	t2.ItemCode
	,t2.ItemDesc
	,t1.UPC
into #tmp_data_output
from
	q_UPCUsage t1
	left outer join Static_Xref_Table t2 on t2.UPC = t1.UPC
where
	((t2.PrimaryUPC_F = case when @PrimaryFlag is null then 'Y' else @PrimaryFlag end) or 
	(t2.PrimaryUPC_F = case when @PrimaryFlag is null then 'N' else @PrimaryFlag end))
order by
	t2.ItemCode
	,t1.UPC


IF (@SvdTbl is not null)
BEGIN

set @Sql2 = N'select *
into '+@SvdTbl+'
from #tmp_data_output'

exec sp_executesql @Sql2;

END

select *
from #tmp_data_output

drop table
	#tmp_data_output
	,#tmp_data1

GO