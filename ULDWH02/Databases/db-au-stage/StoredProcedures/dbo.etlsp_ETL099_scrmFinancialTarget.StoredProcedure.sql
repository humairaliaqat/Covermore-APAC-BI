USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL099_scrmFinancialTarget]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[etlsp_ETL099_scrmFinancialTarget]	@CountryCode varchar(2),
											@DateRange varchar(30),
											@StartDate varchar(10),
											@EndDate varchar(10)
as

SET NOCOUNT ON

/****************************************************************************************************/
--  Name:           etlsp_ETL099_scrmFinancialTarget
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
select @CountryCode = 'AU', @DateRange = 'Last Month', @StartDate = null, @EndDate = null
*/

--variables
declare @rptStartDate datetime
declare @rptEndDate datetime
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
        @SubjectArea = 'SugarCRM Financial Target',
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
if object_id('[db-au-stage].dbo.etl_scrmTargetAccount') is not null drop table [db-au-stage].dbo.etl_scrmTargetAccount

select @SQL = 'select * into [db-au-stage].dbo.etl_scrmTargetAccount
			  from openquery(db-au-penguinsharp.aust.covermore.com.au
3, ''
				select
					td.CountryCode as Country,
					to1.AlphaCode,
					td.CurrencyCode,
					tc.CompanyName	
				from
					[AU_PenguinSharp_Active].dbo.tblOutlet to1
					inner join [AU_PenguinSharp_Active].dbo.tblDomain td ON td.DomainId = to1.DomainId 
					inner join [AU_PenguinSharp_Active].dbo.tblCompany tc ON td.DomainId = tc.DomainId
				where	
					TD.COUNTRYCODE = ''''' + @CountryCode + ''''' and
					TC.CompanyName = ''''Covermore'''' and not(td.CountryCode = ''''AU'''' and tg.Code in (''''CB'''',''''BW''''))'

if @CountryCode = 'AU'
	select @SQL = @SQL + ' union all
						select
							td.CountryCode as CountryKey,
							to1.AlphaCode,
							td.CurrencyCode,
							tc.CompanyName
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


if object_id('[db-au-stage].dbo.etl_scrmTargetTemp') is not null drop table [db-au-stage].dbo.etl_scrmTargetTemp

select @SQL = 'select * into [db-au-stage].dbo.etl_scrmTargetTemp from openquery(ULDWH02,
		''	select	o.Country, o.AlphaCode, f.[Date], sum(f.SalesTarget) as SalesTarget, sum(f.PolicyCount) as PolicyCount
			from
				[db-au-star].dbo.dimOutlet o
				cross apply
				(
					select convert(datetime,convert(varchar(8),d.[Date],120)+''''01'''') as [Date],
						sum(t.SellPriceTarget) as SalesTarget,
						sum(t.PolicyCountBudget) as PolicyCount
					from
						[db-au-star].dbo.v_ic_factTarget t						
						inner join [db-au-star].dbo.Dim_Date d on t.DateSK = d.Date_SK
					where
						t.OutletSK = o.OutletSK and
						t.OutletReference = ''''Latest Alpha'''' and
						d.Date_SK >= ' + convert(varchar(8),@rptStartDate,112) + ' and 	d.Date_SK < ' + convert(varchar(8),dateadd(d,1,@rptEndDate),112) + ' 
					group by
						convert(datetime,convert(varchar(8),d.[Date],120)+''''01'''')
				) f
			where
				o.Country = ''''' + @CountryCode + '''''
			group by
				o.Country, o.AlphaCode, f.[Date]
			order by 1,2,3
		'')'

exec(@SQL)


if object_id('[db-au-stage].dbo.etl_scrmTarget') is not null drop table [db-au-stage].dbo.etl_scrmTarget
select
	a.Country + '.' + case when a.CompanyName = 'TIP' then 'TIP' else 'CMA' end + '.' + a.AlphaCode as [UniqueIdentifier],
	b.[Date],
	isnull(b.SalesTarget,0) as SalesTarget,
	isnull(b.PolicyCount,0) as PolicyCount,
	a.CurrencyCode	
into [db-au-stage].dbo.etl_scrmTarget
from
	[db-au-stage].dbo.etl_scrmTargetAccount a
	inner join [db-au-stage].dbo.etl_scrmTargetTemp b on
		a.Country = b.Country collate database_default and
		a.AlphaCode = b.AlphaCode collate database_default


if object_id('[db-au-ods].dbo.scrmFinancialTarget') is null 
begin
	create table [db-au-ods].dbo.scrmFinancialTarget
	(
		BIRowID bigint not null identity(1,1),
		[UniqueIdentifier] varchar(50) null,
		[Date] datetime null,
		[SalesTarget] money null,
		PolicyCount numeric(14,9) null,
		CurrencyCode varchar(10) null,
		LoadDate datetime null,
		UpdateDate datetime null,
		isSynced nvarchar(1) NULL,
		SyncedDateTime datetime null
	)
    create clustered index idx_scrmFinancialTarget_BIRowID on [db-au-ods].dbo.scrmFinancialTarget(BIRowID)
    create nonclustered index idx_scrmFinancialTarget_UniqueIdentifier on [db-au-ods].dbo.scrmFinancialTarget([UniqueIdentifier]) include ([Date])
end


select @sourcecount = count(*)
from [db-au-stage].dbo.etl_scrmTarget

begin transaction
begin try

	delete a
	from
		[db-au-ods].dbo.scrmFinancialTarget a
		inner join [db-au-stage].dbo.etl_scrmTarget b on
			a.[UniqueIdentifier] = b.[UniqueIdentifier] collate database_default and
			a.[Date] = b.[Date]


	insert [db-au-ods].dbo.scrmFinancialTarget with (tablockx)
	(
		[UniqueIdentifier],
		[Date],
		[SalesTarget],
		PolicyCount,
		CurrencyCode,
		LoadDate,
		UpdateDate,
		isSynced,
		SyncedDateTime
	)
	select
		[UniqueIdentifier],
		[Date],
		[SalesTarget],
		PolicyCount,
		CurrencyCode,
		getdate(),
		null,
		null,
		null
	from
		[db-au-stage].dbo.etl_scrmTarget

	
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
