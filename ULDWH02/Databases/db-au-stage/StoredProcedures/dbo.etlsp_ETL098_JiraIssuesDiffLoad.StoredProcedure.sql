USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL098_JiraIssuesDiffLoad]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_ETL098_JiraIssuesDiffLoad]
  --@LoadDuration int
  @StartDate date,
  @EndDate date 
AS
begin
/************************************************************************************************************************************
Author:         Ratnesh
Date:           20180316
Prerequisite:   Python script for Rest API call should be successful and data should be populated in staging table.
Description:    This procedure loads Jira issues data from staging table to EDW table.

Change History:
                20180316 - RS - Procedure created
				20180625 - RS - Added additional effor related columns

*************************************************************************************************************************************/

--declare @StartDate datetime= getdate()- @LoadDuration
--declare @EndDate datetime =getdate()
DECLARE @Rows int

if object_id('[db-au-cmdwh].dbo.JiraIssues') is null
    begin

		CREATE TABLE [db-au-cmdwh].[dbo].[JiraIssues](
			[IssueKey] [varchar](255) NULL,
			[JiraIssueId] [int] NULL,
			[JiraIssueKey] [varchar](255) NULL,
			[IssueSummary] [varchar](500) NULL,
			[IssueDescription] [text] NULL,
			[ReporterName] [varchar](255) NULL,
			[ReporterEmail] [varchar](255) NULL,
			[AssigneeName] [varchar](255) NULL,
			[AssigneeEmail] [varchar](255) NULL,
			[CreatedDate] [datetime] NULL,
			[DueDate] [datetime] NULL,
			[LastUpdatedDate] [datetime] NULL,
			IssueStatus [varchar](255) NULL,
			IssueType [varchar](255) NULL,
			IssuePriority [varchar](255) NULL,
			IssueProjectKey [varchar](255) NULL,
			IssueProjectName [varchar](500) NULL,
			IssueLabels [varchar](500) NULL,
			IssueComponent [varchar](500) NULL,
			IssueResolution [varchar](255) NULL,
			[isLatest] [char](1) NULL default 'Y',
			[ETLInsertDate] [datetime] NULL default getdate(),
			[ETLUpdateDate] [datetime] NULL,
			Urgency [varchar](50) NULL,
			Effort [float](10) NULL,
			Effort_Done [float](10) NULL,
			StoryPoints [float]
		) ON [PRIMARY]

        create clustered index idxJiraIssuesIssueKey on [db-au-cmdwh].dbo.JiraIssues(IssueKey)

    end
------------------------------------ISSUES DATA PROCESSING BLOCK--------------------------------------------------------------------------------
begin transaction
begin try

Print('Parameter values are @StartDate:'+cast(@StartDate as varchar)+' and @EndDate:'+cast(@EndDate as varchar))

Print('########Jira ISSUES EDW Layer ETL started@:'+cast(getdate() as varchar))

--find all the records already in EDW table which has last_modified date time earlier than the stating table record. Latest record will be inserted in next step.
update edwTab
set isLatest='N',ETLUpdateDate=getdate()
from [db-au-cmdwh].[dbo].JiraIssues edwTab
join [db-au-stage].[dbo].[StgJiraIssues] stgTab
on (edwTab.IssueKey =stgTab.JiraIssueKey and edwTab.isLatest='Y' and stgTab.LastUpdatedDate> edwTab.LastUpdatedDate)
where (cast(convert(char(11), stgTab.CreatedDate, 113) as datetime) between @StartDate and @EndDate
 or cast(convert(char(11), stgTab.LastUpdatedDate, 113) as datetime) between @StartDate and @EndDate);
 
 SELECT @Rows=@@ROWCOUNT
 Print(cast(@Rows as varchar)+' records marked as old record.')


 --insert all differential records or recently modified records from staging table to EDW table.
insert into [db-au-cmdwh].[dbo].JiraIssues(IssueKey,JiraIssueId,JiraIssueKey,
    IssueSummary        ,
    IssueDescription    ,--this column is text type and not comparable
    ReporterName        ,
    ReporterEmail       ,
    AssigneeName        ,
    AssigneeEmail       ,
    CreatedDate         ,
    DueDate             ,
    LastUpdatedDate     ,
    IssueStatus         ,
    IssueType           ,
    IssuePriority       ,
    IssueProjectKey     ,
    IssueProjectName    ,
    IssueLabels         ,
    IssueComponent      ,
    IssueResolution     ,
	Urgency				,
	Effort				,
	Effort_Done			,
	StoryPoints) 
 select 	JiraIssueKey,JiraIssueId,JiraIssueKey            ,
    IssueSummary        ,
    IssueDescription    ,
    ReporterName        ,
    ReporterEmail       ,
    AssigneeName        ,
    AssigneeEmail       ,
    CreatedDate         ,
    DueDate             ,
    LastUpdatedDate     ,
    IssueStatus         ,
    IssueType           ,
    IssuePriority       ,
    IssueProjectKey     ,
    IssueProjectName    ,
    IssueLabels         ,
    IssueComponent      ,
    IssueResolution     ,
	Urgency				,
	Effort				,
	Effort_Done			,
	StoryPoints from [db-au-stage].[dbo].[StgJiraIssues]
 where (cast(convert(char(11), CreatedDate, 113) as datetime) between @StartDate and @EndDate
 or cast(convert(char(11),LastUpdatedDate , 113) as datetime) between @StartDate and @EndDate)
and JiraIssueKey not in (
 select 	stgTab.JiraIssueKey from [db-au-stage].[dbo].[StgJiraIssues] stgTab
 join [db-au-cmdwh].[dbo].JiraIssues edwTab
 on  edwTab.JiraIssueKey =stgTab.JiraIssueKey
where edwTab.isLatest='Y'
and stgTab.LastUpdatedDate <= edwTab.LastUpdatedDate)
;

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
 Print('########Jira ISSUES EDW Layer ETL finished@:'+cast(getdate() as varchar)+char(10))
 end try

 begin catch
        if @@trancount > 0
        rollback;
		print('Error occurred during issues data processing'+error_line())
        exec syssp_genericerrorhandler 'Error while executing etlsp_ETL098_JiraIssuesDiffLoad';
 end catch
 end

 --first time load manual execution
--exec etlsp_ETL098_JiraIssuesDiffLoad '20000101','20180409'
GO
