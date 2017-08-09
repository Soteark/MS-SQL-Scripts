select
	t2.client_net_address
	,t1.[program_name]
	,t1.[host_name]
	,t1.login_name
	,count(t2.session_id) [conn_count]
from
	sys.dm_exec_sessions t1
	inner join sys.dm_exec_connections t2 on t2.session_id = t1.session_id
group by
	t2.client_net_address
	,t1.[program_name]
	,t1.[host_name]
	,t1.login_name
order by
	t2.client_net_address
	,t1.[program_name]
	
	--test commit
