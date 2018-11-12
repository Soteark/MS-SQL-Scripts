DECLARE
	@Test1 AS TABLE(
		store_id varchar(50)
		,div_id varchar(50)
		,dept_id varchar(50)
		,major varchar(50)
		,val1 decimal(18,4))

insert into @Test1
select 'S:413', 'Div:1', 'Dept:1', 'Mjr:600',50
union all
select 'S:413', 'Div:1', 'Dept:1', 'Mjr:700',25
union all
select 'S:413', 'Div:1', 'Dept:17', 'Mjr:500',30
union all
select 'S:413', 'Div:2', 'Dept:5', 'Mjr:300',40
union all
select 'S:426', 'Div:1', 'Dept:1', 'Mjr:600',15
union all
select 'S:426', 'Div:1', 'Dept:1', 'Mjr:900',10
union all
select 'S:426', 'Div:1', 'Dept:2', 'Mjr:300',65

;with
	q_data1 as (
		select
			case when grouping(store_id) = 1 then 'GRAND TOTAL' else store_id end [Store]
			,case when grouping(div_id) = 1 then '' else div_id end [Division]
			,case when grouping(dept_id) = 1 then '' else dept_id end [Dept]
			,case when grouping(major) = 1 then '' else major end [Major]
			,sum(val1) [val1]
			,case
				when grouping(major) = 0 then sum(sum(val1)) over (partition by store_id,div_id,dept_id,grouping(major))
				when grouping(dept_id) = 0 then sum(sum(val1)) over (partition by store_id,div_id,grouping(dept_id),grouping(major))
				when grouping(div_id) = 0 then sum(sum(val1)) over (partition by store_id,grouping(div_id),grouping(dept_id),grouping(major))
				when grouping(store_id) = 0 then sum(sum(val1)) over (partition by grouping(store_id),grouping(div_id),grouping(dept_id),grouping(major))
				when grouping(store_id) = 1 then sum(sum(val1)) over (partition by grouping(store_id),grouping(div_id),grouping(dept_id),grouping(major))
			end [ptt_total]

			,grouping(store_id) [store_grp]
			,grouping(div_id) [div_grp]
			,grouping(dept_id) [dept_grp]
			,grouping(major) [major_grp]
		from @Test1
		group by grouping sets (
			()
			,(store_id)
			,(store_id,div_id)
			,(store_id,div_id,dept_id)
			,(store_id,div_id,dept_id,major)))


select * from q_data1
order by
	Store
	,Division
	,Dept
	,Major

/*-- Upate this later --*/