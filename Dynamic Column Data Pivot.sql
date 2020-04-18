--Create Data Table
if object_id('tmp_data1') is not null
	drop table tmp_data1
go

/*=====Create Initial Data Set=====*/
select
	t1.Static_Col
	,'PvtCol '+cast(t1.PvtCol as varchar(2))+' KPI_1' PvtCol_1
	,'PvtCol '+cast(t1.PvtCol as varchar(2))+' KPI_2' PvtCol_2
	,sum(t1.KPI_1) [KPI_1]
	,sum(t1.KPI_2) [KPI_2]
into tmp_data1
from Data_Table t1
order by
	t1.PvtCol
	,t1.Static_Col
go

if object_id('tmp_data2') is not null
	drop table tmp_data2
go

--Select Distinct Column Names and order
select
	distinct
	PvtCol_1,
	PvtCol_2,
	cast(rtrim(ltrim(replace(replace(PvtCol_1,'PvtCol ',''),' KPI_1',''))) as int) PvtCol
into tmp_data2
from tmp_Data1
order by PvtCol
go

--Start Pivot
declaresdfsdf
	@cols1 nvarchar(max),
	@cols2 nvarchar(max),
	@select_cols1 nvarchar(max),
	@select_cols2 nvarchar(max),
	@sql nvarchar(max)

--set retail cols to pivot by	
set @cols1 = '['+
			stuff((
				select
					'],['+
					PvtCol_1
				from tmp_data2
				for xml path('')),1,3,'')+']'

----set untis cols to pivot by				
set @cols2 = '['+
			stuff((
				select
					'],['+
					PvtCol_2
				from tmp_data2
				for xml path('')),1,3,'')+']'				

--set pivoted retail columns for select statement				
set @select_cols1 = stuff((select
						',sum(['+PvtCol_1+']) as ['+PvtCol_1+']'
						from tmp_data2
						for xml path('')),1,1,'')

--set pivoted units columns for select statement						
set @select_cols2 = stuff((select
						',sum(['+PvtCol_2+']) as ['+PvtCol_2+']'
						from tmp_data2
						for xml path('')),1,1,'')						

--Write Query for pivot table on data table using variables
set @sql = N'
			select
				Static_Col
				,'+@select_cols1+','+@select_cols2+'
			from ( select * from tmp_data1 ) as tmp_tbl1
			pivot ( sum(KPI_1) for PvtCol_1 in('+@cols1+')) as pvt1
			pivot ( sum(KPI_2) for PvtCol_2 in('+@cols2+')) as pvt2
			group by Static_Col
			order by Static_Col'

-- execute query
exec sp_executesql @sql
