/*Non Temp DB Table Check with Drop*/
if exist ( select 1 from information_schema.tables where table_name = '[TABLE NAME]' )
	drop table [TABLE NAME];

/*Temp DB Table Check with Drop*/
if object_id('tempdb..#[TABLE NAME]') is not null
	drop table #[TABLE NAME];