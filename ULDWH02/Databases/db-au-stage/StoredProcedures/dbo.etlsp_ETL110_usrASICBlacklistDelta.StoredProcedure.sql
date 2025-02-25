USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL110_usrASICBlacklistDelta]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--CREATE 
CREATE 
procedure [dbo].[etlsp_ETL110_usrASICBlacklistDelta]
    --@StartDate date = null,
    --@EndDate date = null
    
as
begin
/************************************************************************************************************************************
Author:         Ratnesh Sharma
Date:           20181128
Description:    Load Banned and Disqualified Persons Data
Parameters:     
Change History:
                20181128 - RS - created

*************************************************************************************************************************************/
    set nocount on

--uncomment to debug
/*
	declare @StartDate datetime
	declare @EndDate datetime
	select @StartDate = '2018-10-11', @EndDate = '2018-10-14'


    declare
        @batchid int,
        @start date,
        @end date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

*/

    if object_id('[db-au-cmdwh].dbo.usrASICBlacklist') is null

	CREATE TABLE [db-au-cmdwh]..[usrASICBlacklist](
    [BanRegisterName] [varchar](255) NULL,
	[FullNameASIC] [varchar](255) NULL,
	[FirstName] [varchar](255) NULL,
	[MiddleName] [varchar](255) NULL,
	[LastName] [varchar](255) NULL,
	[FullNamePenguin] [varchar](255) NULL,
	[BanType] [varchar](255) NULL,
	[BanDocumentNumber] [varchar](255) NULL,
	[BanStartDate] [datetime] NULL,
	[BanEndDate] [datetime] NULL,
	[LocalAddress] [varchar](255) NULL,
	[State] [varchar](255) NULL,
	[PostCode] [varchar](255) NULL,
	[Country] [varchar](255) NULL,
	[Comments] [varchar](1000) NULL,
	index usrASICBlacklist_idx(FullNamePenguin)
    ) 

	else

	begin transaction
	

	insert into [db-au-cmdwh].[dbo].[usrASICBlacklist](BanRegisterName,FullNameASIC,FirstName,MiddleName,LastName,FullNamePenguin,BanType,BanDocumentNumber,BanStartDate,BanEndDate,LocalAddress,State,PostCode,Country,Comments)
	select BanRegisterName,FullNameASIC,FirstName,MiddleName,LastName,FullNamePenguin,BanType,BanDocumentNumber,BanStartDate,BanEndDate,LocalAddress,State,PostCode,Country,Comments
	from [db-au-stage].dbo.STG_usrASICBlacklist
	where 
	    isnull(BanRegisterName,'x')+isnull(FullNameASIC,'x')+isnull(BanType,'x')+isnull(BanDocumentNumber,'x')+cast(isnull(BanStartDate,'1900-01-01') as nvarchar)+cast(isnull(BanEndDate,'1900-01-01') as nvarchar)+isnull(LocalAddress,'x')+isnull(State,'x')+isnull(PostCode,'x')+isnull(Country,'x')+isnull(Comments,'x')
		not in (select isnull(BanRegisterName,'x')+isnull(FullNameASIC,'x')+isnull(BanType,'x')+isnull(BanDocumentNumber,'x')+cast(isnull(BanStartDate,'1900-01-01') as nvarchar)+cast(isnull(BanEndDate,'1900-01-01') as nvarchar)+isnull(LocalAddress,'x')+isnull(State,'x')+isnull(PostCode,'x')+isnull(Country,'x')+isnull(Comments,'x')
		from [db-au-cmdwh].[dbo].[usrASICBlacklist]);

	commit;--this is not effective when proc is called from python
	print('procedure [db-au-stage].[dbo].[etlsp_ETL110_usrASICBlacklistDelta] completed successfully');
	
end


GO
