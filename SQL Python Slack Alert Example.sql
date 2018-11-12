
------------------------------------------------------------------------------->
--Carriage return above to prevent "GOIF". Do Not Remove.
------------------------------------------------------------------------------->
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, QUOTED_IDENTIFIER ON
GO
-- CHECK AND CREATE PROCEDURE ------------------------------------------------->
EXEC usp_Common_CheckProcAndCreate 
	@vSchemaName = 'dbo'
	,@vProcedureName = 'cusp_SlackSystemAlerts_LowDiskSpace'
GO

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
** dbo.cusp_SlackSystemAlerts_LowDiskSpace.StoredProcedure.sql
** Notifies people in Slack of low disk space remaining on the server
**
** |   DATE   |  BY  | Zoho ID | Modification(s)
** |----------|------|---------|----------------------------------------------->
** | 20181104 |  CY  |         | Creation
** |          |      |         | 
** |          |      |         | 
** |          |      |         |
** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
ALTER PROCEDURE [dbo].[cusp_SlackSystemAlerts_LowDiskSpace] (
	@iUserID INT = NULL
	,@bDebug BIT = 0
	,@iGBThreshold INT = 100
)
AS
BEGIN

	SET NOCOUNT ON;
	SET ARITHABORT ON;
	
	DECLARE
		@vErrMsg 				NVARCHAR(MAX)
		,@vLocationOfOccurrence NVARCHAR(128) = ISNULL(OBJECT_NAME(@@PROCID),'dbo.cusp_SlackSystemAlerts_LowDiskSpace')
		,@nScript NVARCHAR(MAX)
		,@nDriveLetter NVARCHAR(5) = NULL
		,@fSpaceFree FLOAT = NULL


	DECLARE
		@tDriveSpace TABLE (
			Drive NVARCHAR(5)
			,MBFree FLOAT
			,Processed BIT DEFAULT 0);

	INSERT INTO @tDriveSpace ( Drive ,
	                           MBFree )
	EXEC sys.xp_fixeddrives;


	DELETE FROM @tDriveSpace
	WHERE MBFree > (@iGBThreshold * 1000)

	SELECT * FROM @tDriveSpace


	WHILE EXISTS ( SELECT 1 FROM @tDriveSpace WHERE ISNULL(Processed,0) = 0 )
	BEGIN

		SELECT TOP 1
			@nDriveLetter = DS.Drive
			,@fSpaceFree = DS.MBFree
		FROM @tDriveSpace DS
		WHERE ISNULL(DS.Processed,0) = 0;


		SET @nScript = N'
import json
import requests

webhook_url = ''https://hooks.slack.com/services/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''
slack_data = {''text'': "_Low Disk Space Notification!_ *Server:* Nike US PnP Dev DB *Drive:* '+@nDriveLetter+' *Remaining Space:* '+CAST(@fSpaceFree AS NVARCHAR(MAX))+'" }

response = requests.post(
	webhook_url, data=json.dumps(slack_data),
	headers={''Content-Type'': ''application/json''}
)
if response.status_code != 200:
	raise ValueError(
		''Request to slack returned an error %s, the response is:\n%s''
		% (response.status_code, response.text)
	)
';

		EXEC sys.sp_execute_external_script
			@language = N'Python'
			,@script = @nScript;

		UPDATE @tDriveSpace
		SET Processed = 1
		WHERE Drive = @nDriveLetter;

	END

END
GO
------------------------------------------------------------------------------->
--	Method Update/Addition
------------------------------------------------------------------------------->
EXEC usp_Common_AddUpdate_StoredProcedureLookup
	'dbo.cusp_SlackSystemAlerts_LowDiskSpace'
	,'dbo.cusp_SlackSystemAlerts_LowDiskSpace'
	,'Notifies people in Slack of low disk space remaining on the server';
GO
------------------------------------------------------------------------------->
-- ADD EXTENDED PROPERTIES
------------------------------------------------------------------------------->
EXEC usp_Common_AddUpdateExtendedProperties
	@Objective = 'Notifies people in Slack of low disk space remaining on the server'
	,@Description = 'Notifies people in Slack of low disk space remaining on the server'
	,@Example  = ''
	,@ObjectName ='cusp_SlackSystemAlerts_LowDiskSpace'
	,@SchemaName = 'dbo'
	,@ParameterName = NULL
GO
------------------------------------------------------------------------------->
-- Carriage return below to prevent "GOIF". Do Not Remove.
------------------------------------------------------------------------------->
