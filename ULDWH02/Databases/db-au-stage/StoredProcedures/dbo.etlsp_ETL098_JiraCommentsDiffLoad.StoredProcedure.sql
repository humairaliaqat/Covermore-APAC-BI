USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL098_JiraCommentsDiffLoad]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL098_JiraCommentsDiffLoad]
 --@LoadDuration int
 @StartDate date,
 @EndDate date
AS
begin
/************************************************************************************************************************************
Author:         Ratnesh
Date:           20180316
Prerequisite:   Python script for Rest API call should be successful and data should be populated in staging table.
Description:    This procedure loads Jira comments data from staging table to EDW table.

Change History:
                20180316 - RS - Procedure created

*************************************************************************************************************************************/

--declare @StartDate datetime= getdate()- @LoadDuration
--declare @EndDate datetime =getdate()
DECLARE @Rows int

if object_id('[db-au-cmdwh].dbo.JiraComments') is null
    begin
	CREATE TABLE [db-au-cmdwh].[dbo].[JiraComments](
        [IssueKey] [varchar](255) NULL,
		[CommentKey] [int] NULL,
		[JiraIssueId] [int] NULL,
		[JiraIssueKey] [varchar](255) NULL,
		[JiraCommentId] [int] NULL,
        [AuthorKey] [varchar](500) NULL,
		[AuthorName] [varchar](500) NULL,
	    [AuthorEmailAddress] [varchar](500) NULL,
		[UpdateAuthorKey] [varchar](500) NULL,
		[UpdateAuthorName] [varchar](500) NULL,
    	[UpdateAuthorEmailAddress] [varchar](500) NULL,
	    [Body] [text] NULL,
        [CreatedDate] [datetime] NULL,
	    [LastUpdatedDate] [datetime] NULL,
	    [isLatest] [char](1) NULL default 'Y',
	    [ETLInsertDate] [datetime] NULL default getdate(),
	    [ETLUpdateDate] [datetime] NULL,
		PublicComment varchar(50)
) ON [PRIMARY]

create clustered index idx_JiraComments_IssueKeyCommentKey on [db-au-cmdwh].dbo.JiraComments(CommentKey,IssueKey)

end
------------------------------------COMMENTS DATA PROCESSING BLOCK--------------------------------------------------------------------------------
begin transaction

begin try

  Print('Parameters passed are @StartDate:'+cast(@StartDate as varchar)+' and @EndDate:'+cast(@EndDate as varchar))

  Print('########Jira COMMENTS EDW Layer ETL started@:'+cast(getdate() as varchar))


--find all the records already in EDW table which has last_modified date time earlier than the stating table record. Latest record will be inserted in next step.
	update edwTab
	set isLatest='N',ETLUpdateDate=getdate()
	from [db-au-cmdwh].[dbo].JiraComments edwTab
	join [db-au-stage].[dbo].[StgJiraComments] stgTab
	on (edwTab.CommentKey =stgTab.JiraCommentId and edwTab.isLatest='Y' and stgTab.LastUpdatedDate> edwTab.LastUpdatedDate)
	where (cast(convert(char(11), stgTab.CreatedDate, 113) as datetime) between @StartDate and @EndDate
	 or cast(convert(char(11), stgTab.LastUpdatedDate, 113) as datetime) between @StartDate and @EndDate);
 
 SELECT @Rows=@@ROWCOUNT
 Print(cast(@Rows as varchar)+' records marked as old record.')


 --insert all differential records or recently modified records from staging table to EDW table.
 insert into [db-au-cmdwh].[dbo].JiraComments(	  
		[IssueKey],
		[CommentKey],
		[JiraIssueId] ,
		[JiraIssueKey],
		[JiraCommentId],
	    [AuthorKey],
		[AuthorName],
	    [AuthorEmailAddress] ,
		[UpdateAuthorKey],
		[UpdateAuthorName],
	    [UpdateAuthorEmailAddress] ,
	    [Body],
        [CreatedDate] ,
	    [LastUpdatedDate],
		[PublicComment] ) 
 select [JiraIssueKey],
        [JiraCommentId],
        [JiraIssueId] ,
		[JiraIssueKey],
		[JiraCommentId],
		[AuthorKey],
        [AuthorName],
	    [AuthorEmailAddress] ,
		[UpdateAuthorKey],
		[UpdateAuthorName],
	    [UpdateAuthorEmailAddress] ,
	    [Body],
        [CreatedDate] ,
	    [LastUpdatedDate],
		[PublicComment]       from [db-au-stage].[dbo].[StgJiraComments]
	 where (cast(convert(char(11), CreatedDate, 113) as datetime) between @StartDate and @EndDate
	 or cast(convert(char(11), LastUpdatedDate, 113) as datetime) between @StartDate and @EndDate)
	and JiraCommentId not in (
	 select 	stgTab.JiraCommentId from [db-au-stage].[dbo].[StgJiraComments] stgTab
	 join [db-au-cmdwh].[dbo].JiraComments edwTab
	 on  edwTab.CommentKey =stgTab.JiraCommentId
	where edwTab.isLatest='Y'
	and stgTab.LastUpdatedDate <= edwTab.LastUpdatedDate)
	;

  SELECT @Rows=@@ROWCOUNT

  commit;
  print('Total '+ ltrim(str(@Rows)) + ' Records inserted.')
  Print('########Jira COMMENTS EDW Layer ETL finished@:'+cast(getdate() as varchar)+char(10))
 end try
 
 begin catch
        if @@trancount > 0
        rollback;
		print('Error occurred during comments data processing'+error_line())
        exec syssp_genericerrorhandler 'Error while executing etlsp_ETL098_JiraCommentsDiffLoad';
		--raiseerror('jo', 11, 160073);
 end catch
 end
GO
