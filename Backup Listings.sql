-- Display Backup Listings and KPI Size Information
select
	t1.server_name
	,t1.database_name
	,t1.recovery_model
	,t1.user_name
	,t1.database_creation_date
	,t1.backup_start_date
	,t1.backup_finish_date
	,t1.backup_size
from msdb.dbo.backupset t1
where
	--t1.type = 'D'
	t1.backup_start_date >= '7/1/13'
order by backup_start_date desc

/*--
--removed some stuff
--*/