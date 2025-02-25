USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL099_scrmPolicyComment]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[etlsp_ETL099_scrmPolicyComment]		@CountryCode varchar(2),
															@DateRange varchar(30),
															@StartDate varchar(10),
															@EndDate varchar(10)
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           etlsp_ETL099_scrmPolicyComment
--  Author:         Linus Tor
--  Date Created:   20180515
--  Description:    This stored procedure returns previous day policy comment
--
--  Parameters:     @Country: Valid country code (AU, NZ, MY, SG, US, UK etc...)
--					@DateRange: Standard date range. Use _User Defined for custom data range.
--					@StartDate: Only required if DateRange = _User Defined. Format: yyyy-mm-dd (eg. 2018-01-01)
--					@EndDate: Only required if DateRange = _User Defined. Format: yyyy-mm-dd (eg. 2018-01-01)
--  
--  Change History: 20180515 - LT - Created
--					20180621 - LT - Added isSynced and SyncedDateTime columns
--					20181016 - LT - Excludes CBA and Bankwest outlets
--                  
/****************************************************************************************************/

--uncomment to debug
/*
declare @CountryCode varchar(2)
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @CountryCode = 'AU', @DateRange = 'Month-To-Date', @StartDate = null, @EndDate = null
*/

--variables
declare @rptStartDate datetime
declare @rptEndDate datetime
declare @rptYesterday datetime
declare @SQL varchar(8000)


declare
    @batchid int,
    @start datetime,
    @end datetime,
    @name varchar(50),
	@sourcecount int

select
    @name = object_name(@@procid)

begin try    
    --check if this is running on batch

    exec syssp_getrunningbatch
        @SubjectArea = 'SugarCRM Policy Comment',
        @BatchID = @batchid out,
        @StartDate = @start out,
        @EndDate = @end out

    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Running'

    select 
        @rptStartDate = @start, 
        @rptEndDate = @end

end try
    
begin catch
    
    --or manually
    
    set @batchid = -1

    --get date range
    if @DateRange = '_User Defined'
        select 
            @rptStartDate = @StartDate, 
            @rptEndDate = @EndDate
    else
        select 
            @rptStartDate = StartDate,
            @rptEndDate = EndDate
        from 
            [db-au-ods].dbo.vDateRange
        where 
            DateRange = @DateRange

end catch

if object_id('[db-au-stage].dbo.etl_scrmPolicyComment') is not null drop table [db-au-stage].dbo.etl_scrmPolicyComment

select @SQL = 'select * into [db-au-stage].dbo.etl_scrmPolicyComment from openquery([db-au-penguinsharp.aust.covermore.com.au],
''
	select
		td.CountryCode + ''''.'''' + tc.Code + ''''.'''' +  to1.AlphaCode as [UniqueIdentifier],
		p.PolicyNumber,
		pacc.CallCommentID,
		[AU_PenguinSharp_Active].dbo.UTCToLocalTimeZone(pacc.CommentDate,d.TimeZoneCode) as CommentDateTime,
		pacc.Comment,
		u.[User],
		r.[Subject]
	from
		[AU_PenguinSharp_Active].dbo.tblPolicy p
		inner join [AU_PenguinSharp_Active].dbo.tblPolicyAdminCallComment pacc on 
			p.PolicyID = pacc.PolicyID
		inner join [AU_PenguinSharp_Active].dbo.tblOutlet to1 on p.AlphaCode = to1.AlphaCode and p.DomainID = to1.DomainID
		inner join [AU_PenguinSharp_Active].dbo.tblDomain td ON td.DomainId = to1.DomainId 
		inner join [AU_PenguinSharp_Active].dbo.tblCompany tc ON td.DomainId = tc.DomainId
		inner join [AU_PenguinSharp_Active].dbo.tblDomain d on p.DomainId = d.DomainId
		inner join [AU_PenguinSharp_Active].dbo.tblSubGroup tsg ON tsg.ID = to1.SubGroupID
		inner join [AU_PenguinSharp_Active].dbo.tblGroup tg ON tsg.GroupID = tg.ID
		outer apply
		(
			select top 1 FirstName + '''' '''' + LastName as [User]
			from [AU_PenguinSharp_Active].dbo.tblCRMUser
			where ID = pacc.CRMUserID
		) u
		outer apply
		(
			select [Value] as [Subject]
			from
				[AU_PenguinSharp_Active].dbo.tblReferenceValue rv
				inner join [AU_PenguinSharp_Active].dbo.tblReferenceValueGroup rvg on rv.GroupID = rvg.ID
			where
				rv.ID = pacc.ReasonID and
				rvg.ID = 33	 and								
				rvg.DomainID = p.DomainId	
		) r
	where
		td.CountryCode = ''''' + @CountryCode + ''''' and
		tc.CompanyName = ''''Covermore'''' and
		not 
		(
			td.CountryCode = ''''AU'''' and
			tg.Code in (''''CB'''',''''BW'''')
		) and 
		pacc.CommentDate >= ''''' + convert(varchar(19),[db-au-ods].[dbo].[xfn_ConvertLocaltoUTC](@rptStartDate,'AUS Eastern Standard Time'),120) + ''''' and
		pacc.CommentDate < ''''' + convert(varchar(19),dateadd(d,1,[db-au-ods].[dbo].[xfn_ConvertLocaltoUTC](@rptEndDate,'AUS Eastern Standard Time')),120) + ''''''

if @CountryCode = 'AU'
	select @SQL = @SQL + ' union all

						select
							td.CountryCode + ''''.'''' + tc.Code + ''''.'''' +  to1.AlphaCode as [UniqueIdentifier],
							p.PolicyNumber,
							pacc.CallCommentID,
							[AU_TIP_PenguinSharp_Active].dbo.UTCToLocalTimeZone(pacc.CommentDate,d.TimeZoneCode) as CommentDateTime,
							pacc.Comment,
							u.[User],
							r.[Subject]
						from
							[AU_TIP_PenguinSharp_Active].dbo.tblPolicy p
							inner join [AU_TIP_PenguinSharp_Active].dbo.tblPolicyAdminCallComment pacc on 
								p.PolicyID = pacc.PolicyID
							inner join [AU_TIP_PenguinSharp_Active].dbo.tblOutlet to1 on p.AlphaCode = to1.AlphaCode and p.DomainID = to1.DomainID
							inner join [AU_TIP_PenguinSharp_Active].dbo.tblSubGroup sg on to1.SubGroupID = sg.ID
							inner join [AU_TIP_PenguinSharp_ACtive].dbo.tblGroup tg on sg.GroupID = tg.ID
							inner join [AU_TIP_PenguinSharp_Active].dbo.tblDomain td ON td.DomainId = to1.DomainId 
							inner join [AU_TIP_PenguinSharp_Active].dbo.tblCompany tc ON td.DomainId = tc.DomainId
							inner join [AU_TIP_PenguinSharp_Active].dbo.tblDomain d on p.DomainId = d.DomainId
							outer apply
							(
								select top 1 FirstName + '''' '''' + LastName as [User]
								from [AU_TIP_PenguinSharp_Active].dbo.tblCRMUser
								where ID = pacc.CRMUserID
							) u
							outer apply
							(
								select [Value] as [Subject]
								from
									[AU_TIP_PenguinSharp_Active].dbo.tblReferenceValue rv
									inner join [AU_TIP_PenguinSharp_Active].dbo.tblReferenceValueGroup rvg on rv.GroupID = rvg.ID
								where
									rv.ID = pacc.ReasonID and
									rvg.ID = 33	 and								
									rvg.DomainID = p.DomainId	
							) r
						where
							td.CountryCode = ''''' + @CountryCode + ''''' and
							tc.CompanyName = ''''TIP'''' and
							tg.[Name] not in (''''AANT'''',''''Adventure World'''',''''NRMA'''',''''RAA'''',''''RAC'''',''''RACQ'''',''''RACT'''',''''RACV'''') and
							pacc.CommentDate >= ''''' + convert(varchar(19),[db-au-ods].[dbo].[xfn_ConvertLocaltoUTC](@rptStartDate,'AUS Eastern Standard Time'),120) + ''''' and
							pacc.CommentDate < ''''' + convert(varchar(19),dateadd(d,1,[db-au-ods].[dbo].[xfn_ConvertLocaltoUTC](@rptEndDate,'AUS Eastern Standard Time')),120) + '''''

'')'

else
	select @SQL = @SQL + ' '') a'

execute(@SQL)


if object_id('[db-au-ods].dbo.scrmPolicyComment') is null
begin
	create table [db-au-ods].dbo.scrmPolicyComment
	(
		BIRowID bigint not null identity(1,1),
		[UniqueIdentifier] varchar(50) null,
		PolicyNumber varchar(50) null,
		CallCommentID varchar(50) null,
		CommentDateTime datetime null,
		Comment nvarchar(max) null,
		[User] varchar(100) null,
		[Subject] varchar(200) null,
		LoadDate datetime null,
		UpdateDate datetime null,
		isSynced nvarchar(1) NULL,
		SyncedDateTime datetime null
	)
    create clustered index idx_scrmPolicyComment_BIRowID on [db-au-ods].dbo.scrmPolicyComment(BIRowID)
    create nonclustered index idx_scrmPolicyComment_UniqueIdentifier on [db-au-ods].dbo.scrmPolicyComment([UniqueIdentifier]) include (PolicyNumber, CommentDateTime)
end


select @sourcecount = count(*)
from [db-au-stage].dbo.etl_scrmPolicyComment

begin transaction
begin try

	delete a
	from
		[db-au-ods].dbo.scrmPolicyComment a
		inner join [db-au-stage].dbo.etl_scrmPolicyComment b on
			a.[UniqueIdentifier] = b.[UniqueIdentifier] collate database_default and
			a.CallCommentID = b.CallCommentID


	insert into [db-au-ods].dbo.scrmPolicyComment with (tablockx)
	(
		[UniqueIdentifier],
		PolicyNumber,
		CallCommentID,
		CommentDateTime,
		Comment,
		[User],
		[Subject],
		LoadDate,
		UpdateDate,
		isSynced,
		SyncedDateTime
	)
	select
		[UniqueIdentifier],
		PolicyNumber,
		CallCommentID,
		CommentDateTime,
		Comment,
		[User],
		[Subject],
		getdate() as LoadDate,
		null as updateDate,
		null as isSynced,
		null as SyncedDateTime
	from
		[db-au-stage].dbo.etl_scrmPolicyComment

	
	if @batchid <> - 1
    exec syssp_genericerrorhandler
        @LogToTable = 1,
        @ErrorCode = '0',
        @BatchID = @batchid,
        @PackageID = @name,
        @LogStatus = 'Finished',
        @LogSourceCount = @sourcecount

end try

begin catch

    if @@trancount > 0
        rollback transaction

    if @batchid <> - 1
        exec syssp_genericerrorhandler
            @SourceInfo = 'data refresh failed',
            @LogToTable = 1,
            @ErrorCode = '-100',
            @BatchID = @batchid,
            @PackageID = @name

end catch

if @@trancount > 0
    commit transaction




GO
