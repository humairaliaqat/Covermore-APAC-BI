USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL099_scrmFinancialSummary]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[etlsp_ETL099_scrmFinancialSummary]	@CountryCode varchar(2),
															@DateRange varchar(30),
															@StartDate varchar(10),
															@EndDate varchar(10)
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           etlsp_ETL099_scrmFinancialSummary
--  Author:         Linus Tor
--  Date Created:   20180515
--  Description:    This stored procedure returns previous day sales by account where QuoteCount is >= 1
--					SugarCRM.
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
        @SubjectArea = 'SugarCRM Financial Summary',
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


--get Outlet Unique Identifiers
if object_id('[db-au-stage].dbo.etl_scrmFinancialAccount') is not null drop table [db-au-stage].dbo.etl_scrmFinancialAccount

select @SQL = 'select * into [db-au-stage].dbo.etl_scrmFinancialAccount
			  from openquery([db-au-penguinsharp.aust.covermore.com.au], ''
				select
					td.CountryCode as CountryKey,
					to1.AlphaCode,
					td.CurrencyCode
				from
					[AU_PenguinSharp_Active].dbo.tblOutlet to1
					inner join [AU_PenguinSharp_Active].dbo.tblDomain td ON td.DomainId = to1.DomainId 
					inner join [AU_PenguinSharp_Active].dbo.tblCompany tc ON td.DomainId = tc.DomainId
					inner join [AU_PenguinSharp_Active].dbo.tblSubGroup tsg ON tsg.ID = to1.SubGroupID
					inner join [AU_PenguinSharp_Active].dbo.tblGroup tg ON tsg.GroupID = tg.ID
				where	
					TD.COUNTRYCODE = ''''' + @CountryCode + ''''' and
					TC.CompanyName = ''''Covermore'''' and not(td.CountryCode = ''''AU'''' and tg.Code in (''''CB'''',''''BW''''))'

if @CountryCode = 'AU'
	select @SQL = @SQL + ' union all
						select
							td.CountryCode as CountryKey,
							to1.AlphaCode,
							td.CurrencyCode
						from
							[AU_TIP_PenguinSharp_Active].dbo.tblOutlet to1
							inner join [AU_TIP_PenguinSharp_Active].dbo.tblSubGroup sg on to1.SubGroupID = sg.ID
							inner join [AU_TIP_PenguinSharp_Active].dbo.tblGroup tg on sg.GroupID = tg.ID
							inner join [AU_TIP_PenguinSharp_Active].dbo.tblDomain td ON td.DomainId = to1.DomainId 
							inner join [AU_TIP_PenguinSharp_Active].dbo.tblCompany tc ON td.DomainId = tc.DomainId
						where	
							TD.COUNTRYCODE = ''''' + @CountryCode + ''''' and
							TC.CompanyName = ''''TIP'''' and
							tg.[Name] not in (''''AANT'''',''''Adventure World'''',''''NRMA'''',''''RAA'''',''''RAC'''',''''RACQ'''',''''RACT'''',''''RACV'''')
						'') a'
else
	select @SQL = @SQL + ' '') a'

execute(@SQL)

--get financial summary
if object_id('[db-au-stage].dbo.etl_scrmFinancialSummaryTemp') is not null drop table [db-au-stage].dbo.etl_scrmFinancialSummaryTemp

/*modifying folloiwng lines
select @SQL = 'select * into [db-au-stage].dbo.etl_scrmFinancialSummaryTemp
				from openquery(ULDWH02,''select	o.CountryKey, o.CompanyKey, o.AlphaCode,
												f.[Date],
												sum(f.PolicyCount) as PolicyCount,
												sum(f.QuoteCount) as QuoteCount,
												sum(f.GrossSales) as GrossSales,
												sum(f.Commission) as Commission	
										from
											[db-au-cmdwh].dbo.penOutlet o
											cross apply											
											(
												select
													pt.IssueDate as [Date],
													sum(pt.NewPolicyCount) as PolicyCount,
													sum(pt.GrossPremium) as GrossSales,
													sum(pt.Commission + pt.GrossAdminFee) as Commission,
													0 as QuoteCount
												from
													[db-au-cmdwh].dbo.penPolicy p
													inner join [db-au-cmdwh].dbo.penPolicyTransSummary pt on p.PolicyKey = pt.PolicyKey
												where
													p.OutletAlphaKey = o.OutletAlphaKey and
													pt.PostingDate >= ''''' + convert(varchar(10),@rptStartDate,120) + ''''' and
													pt.PostingDate < ''''' + convert(varchar(10),dateadd(d,1,@rptEndDate),120) + ''''' 
												group by
													pt.IssueDate

												union all

												select
													d.[Date],
													0 as PolicyCount,
													0 as GrossSales,
													0 as Commission,
													sum(q.QuoteCount) as QuoteCount
												from
													[db-au-star].dbo.vfactQuoteSummary q
													inner join [db-au-star].dbo.dimOutlet do on q.OutletSK = do.OutletSK
													inner join [db-au-star].dbo.Dim_Date d on q.DateSK = d.Date_SK			
												where			
													do.OutletAlphaKey = o.OutletAlphaKey and
													d.[Date] >= ''''' + convert(varchar(10),@rptStartDate,120) + ''''' and
													d.[Date] < ''''' + convert(varchar(10),dateadd(d,1,@rptEndDate),120) + ''''' 
												group by
													d.[Date]
											 ) f
										where o.CountryKey = ''''' + @CountryCode + ''''' and o.OutletStatus = ''''Current''''
										group by
											o.CountryKey, 
											o.CompanyKey, 
											o.AlphaCode,
											f.[Date]
										order by 1,2,3,4
										'') '
*/

select @SQL = 'select	o.CountryKey, o.CompanyKey, o.AlphaCode,
												f.[Date],
												sum(f.PolicyCount) as PolicyCount,
												sum(f.QuoteCount) as QuoteCount,
												sum(f.GrossSales) as GrossSales,
												sum(f.Commission) as Commission	
										into [db-au-stage].[dbo].[etl_scrmFinancialSummaryTemp]
										from
											[db-au-cmdwh].dbo.penOutlet o
											cross apply											
											(
												select
													pt.IssueDate as [Date],
													sum(pt.NewPolicyCount) as PolicyCount,
													sum(pt.GrossPremium) as GrossSales,
													sum(pt.Commission + pt.GrossAdminFee) as Commission,
													0 as QuoteCount
												from
													[db-au-cmdwh].dbo.penPolicy p
													inner join [db-au-cmdwh].dbo.penPolicyTransSummary pt on p.PolicyKey = pt.PolicyKey
												where
													p.OutletAlphaKey = o.OutletAlphaKey and
													pt.PostingDate >= ''' + convert(varchar(10),@rptStartDate,120) + ''' and
													pt.PostingDate < ''' + convert(varchar(10),dateadd(d,1,@rptEndDate),120) + ''' 
												group by
													pt.IssueDate

												union all

												select
													d.[Date],
													0 as PolicyCount,
													0 as GrossSales,
													0 as Commission,
													sum(q.QuoteCount) as QuoteCount
												from
													[db-au-star].dbo.vfactQuoteSummary q
													inner join [db-au-star].dbo.dimOutlet do on q.OutletSK = do.OutletSK
													inner join [db-au-star].dbo.Dim_Date d on q.DateSK = d.Date_SK			
												where			
													do.OutletAlphaKey = o.OutletAlphaKey and
													d.[Date] >= ''' + convert(varchar(10),@rptStartDate,120) + ''' and
													d.[Date] < ''' + convert(varchar(10),dateadd(d,1,@rptEndDate),120) + ''' 
												group by
													d.[Date]
											 ) f
										where o.CountryKey = ''' + @CountryCode + ''' and o.OutletStatus = ''Current''
										group by
											o.CountryKey, 
											o.CompanyKey, 
											o.AlphaCode,
											f.[Date]
										order by 1,2,3,4
										 '

--print(@SQL)
exec(@SQL)

if object_id('[db-au-stage].dbo.etl_scrmFinancialSummary') is not null drop table [db-au-stage].dbo.etl_scrmFinancialSummary
select
	f.CountryKey + '.' + case when f.CompanyKey = 'TIP' then 'TIP' else 'CMA' end + '.' + f.AlphaCode as [UniqueIdentifier],
	f.[Date],
	f.PolicyCount,
	f.QuoteCount,
	f.GrossSales,
	o.CurrencyCode,
	f.Commission,
	convert(nvarchar(1),null) as isSynced,
	convert(datetime,null) as SyncedDateTime
into [db-au-stage].dbo.etl_scrmFinancialSummary
from
	[db-au-stage].[dbo].[etl_scrmFinancialSummaryTemp] f
	inner join [db-au-stage].[dbo].[etl_scrmFinancialAccount] o on 
		f.CountryKey = o.CountryKey collate database_default and 
		f.AlphaCode = o.AlphaCode collate database_default
order by 1,2



if object_id('[db-au-ods].dbo.scrmFinancialSummary') is null
begin
	create table [db-au-ods].dbo.scrmFinancialSummary
	(
		BIRowID bigint not null identity(1,1),
		[UniqueIdentifier] varchar(50) null,
		[Date] datetime null,
		PolicyCount int null,
		QuoteCount int null,
		GrossSales money null,
		CurrencyCode varchar(10) null,
		Commission money null,
		LoadDate datetime null,
		UpdateDate datetime null,
		isSynced nvarchar(1) NULL,
		SyncedDateTime datetime null
	)
    create clustered index idx_scrmFinancialSummary_BIRowID on [db-au-ods].dbo.scrmFinancialSummary(BIRowID)
    create nonclustered index idx_scrmFinancialSummary_UniqueIdentifier on [db-au-ods].dbo.scrmFinancialSummary([UniqueIdentifier]) include ([Date])
end


select @sourcecount = count(*)
from [db-au-stage].dbo.etl_scrmFinancialSummary

begin transaction
begin try

	delete a
	from
		[db-au-ods].dbo.scrmFinancialSummary a
		inner join [db-au-stage].dbo.etl_scrmFinancialSummary b on
			a.[UniqueIdentifier] = b.[UniqueIdentifier] and
			a.[Date] = b.[Date]


	insert into [db-au-ods].dbo.scrmFinancialSummary with (tablockx)
	(
		[UniqueIdentifier],
		[Date],
		PolicyCount,
		QuoteCount,
		GrossSales,
		CurrencyCode,
		Commission,
		LoadDate,
		updateDate,
		isSynced,
		SyncedDateTime
	)
	select
		[UniqueIdentifier],
		[Date],
		PolicyCount,
		QuoteCount,
		GrossSales,
		CurrencyCode,
		Commission,
		getdate() as LoadDate,
		null as updateDate,
		null as isSynced,
		null as SyncedDateTime
	from
		[db-au-stage].dbo.etl_scrmFinancialSummary

	
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
