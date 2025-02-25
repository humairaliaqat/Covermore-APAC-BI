USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL098_JiraUsersDiffLoad]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create
--alter 
procedure [dbo].[etlsp_ETL098_JiraUsersDiffLoad]
 --@LoadDuration int
 @StartDate datetime,
 @EndDate datetime
AS
begin
/************************************************************************************************************************************
Author:         Ratnesh
Date:           20180316
Prerequisite:   Python script for Rest API call should be successful and data should be populated in staging table.
Description:    This procedure loads Jira Users data from staging table to EDW table.

Change History:
                20180316 - RS - Procedure created

*************************************************************************************************************************************/

--declare @StartDate datetime= getdate()- @LoadDuration
--declare @EndDate datetime =getdate()
DECLARE @Rows int

if object_id('[db-au-cmdwh].dbo.JiraUsers') is null
    begin
	
CREATE TABLE [db-au-cmdwh].[dbo].[JiraUsers](
    [UserKey] [varchar](500) NULL,
	[JiraUserKey] [varchar](500) NULL,
	[JiraAccountId] [varchar](500) NULL,
	[name] [varchar](500) NULL,
	[emailAddress] [varchar](500) NULL,
	[displayName] [varchar](500) NULL,
	[active] [varchar](10) NULL,
	[timeZone] [varchar](255) NULL,
	[locale] [varchar](255) NULL,
	[isLatest] [char](1) NULL default 'Y',
	[ETLInsertDate] [datetime] NULL default getdate(),
	[ETLUpdateDate] [datetime] NULL
) ON [PRIMARY]

create clustered index idx_DimJiraUsers_UserKey on [db-au-cmdwh].dbo.JiraUsers(UserKey)

end;

------------------------------------USERS DATA PROCESSING BLOCK--------------------------------------------------------------------------------

begin transaction
begin try

Print('########Jira USERS EDW Layer ETL started@:'+cast(getdate() as varchar))

DECLARE @tblDiffUsers TABLE (
    [JiraUserkey] [varchar](500) NULL,
	[JiraAccountId] [varchar](500) NULL,
	[name] [varchar](500) NULL,
	[emailAddress] [varchar](500) NULL,
	[displayName] [varchar](500) NULL,
	[active] [varchar](10) NULL,
	[timeZone] [varchar](255) NULL,
	[locale] [varchar](255) NULL
)

insert @tblDiffUsers
select Jirauserkey,JiraAccountId,name,emailAddress,displayName,active,timeZone,locale from [db-au-stage].[dbo].[StgJiraUsers]
except
select JiraUserKey,JiraAccountId,name,emailAddress,displayName,active,timeZone,locale from [db-au-cmdwh].[dbo].JiraUsers;

SELECT @Rows=@@ROWCOUNT
 Print(cast(@Rows as varchar)+' diferential records found.')

--find all the records already in EDW table containing old data and change latest data identifier as N. Latest record will be inserted in next step.
update edwTab
set isLatest='N',ETLUpdateDate=getdate()
from [db-au-cmdwh].[dbo].JiraUsers edwTab
--join [db-au-stage].[dbo].[StgJiraUsers] stgTab
--on 
where edwTab.isLatest='Y'
 --and (stgTab.CreatedDate between @StartDate and @EndDate
 --or stgTab.LastUpdatedDate between @StartDate and @EndDate)
 and edwTab.Userkey in (select JiraUserkey from @tblDiffUsers);
 
 
 SELECT @Rows=@@ROWCOUNT
 Print(cast(@Rows as varchar)+' records marked as old record.')

--insert all differential records or recently modified records from staging table to EDW table.
insert into [db-au-cmdwh].[dbo].JiraUsers(Userkey,JiraUserkey,JiraAccountId,name,emailAddress,displayName,active,timeZone,locale)
select JiraUserkey,JiraUserkey,JiraAccountId,name,emailAddress,displayName,active,timeZone,locale from @tblDiffUsers;

	SELECT @Rows=@@ROWCOUNT

	--commented out since we are not comparing the data anymore and logic is based on last modified date.
	/*update jI
	set jI.IssueDescription = stg.issueDescription
	from [db-au-cmdwh].[dbo].JiraIssues jI
	inner join [db-au-stage].[dbo].[StgJiraIssues] stg
	on jI.IssueKey=stg.IssueKey
	--and ji.isLatest='Y'
     where (jI.CreatedDate between @StartDate and @EndDate
        or jI.LastUpdatedDate between @StartDate and @EndDate);
		*/
		
 commit;
 
 print('Total '+ ltrim(str(@Rows)) + ' Records inserted.')
 Print('########Jira USERS EDW Layer ETL finished@:'+cast(getdate() as varchar)+char(10))
 end try

 begin catch
        if @@trancount > 0
        rollback;
		print('Error occurred during users data processing'+error_line())
        exec syssp_genericerrorhandler 'Error while executing etlsp_ETL098_JiraUsersDiffLoad';
 end catch
end
GO
