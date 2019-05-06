--Check DB Mail Status==========================================
select * from msdb.dbo.sysmail_sentitems
order by mailitem_id desc

select * from msdb.dbo.sysmail_unsentitems 
order by mailitem_id desc

select * from msdb.dbo.sysmail_faileditems
order by mailitem_id desc

--Send DB Mail==================================================
exec msdb.dbo.sp_send_dbmail
	@profile_name = 'SQLEmail_Account'
	,@recipients = 'user@domain.com'
	,@body = 'The Stored Procedure finished successfully'
	,@subject = 'Automated Success Message'
	,@query = '	select top 10
					t1.Col1
					,t1.Col2
					,t1.Col3
					,t1.Col4
				from Database.dbo.Table t1'
	,@attach_query_result_as_file = 1;

--check one