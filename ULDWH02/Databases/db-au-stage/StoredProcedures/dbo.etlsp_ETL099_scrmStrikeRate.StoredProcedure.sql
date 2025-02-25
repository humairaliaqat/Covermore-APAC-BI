USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL099_scrmStrikeRate]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE   procedure [dbo].[etlsp_ETL099_scrmStrikeRate]	@CountryCode varchar(2),
																@DateRange varchar(30),
																@StartDate datetime,
																@EndDate datetime
as

SET NOCOUNT ON


/****************************************************************************************************/
--  Name:           etlsp_ETL099_scrmStrikeRate
--  Author:         Linus Tor
--  Date Created:   20180515
--  Description:    This stored procedure returns Strike Rate data
--
--  Parameters:     @Country: Valid country code (AU, NZ, MY, SG, US, UK etc...)
--					@DateRange: Standard date range. Use _User Defined for custom data range.
--					@StartDate: Only required if DateRange = _User Defined. Format: yyyy-mm-dd (eg. 2018-01-01)
--					@EndDate: Only required if DateRange = _User Defined. Format: yyyy-mm-dd (eg. 2018-01-01)
--  
--  Change History: 20180515 - LT - Created
--					20180621 - LT - Added isSynced and SyncedDateTime columns
--					20180709 - LT - fixed Strike Rate calculation. It should be [International Travellers Count] / [Ticket Count]
--                  20191202 - EV - Fix the Arithmetic overflow error converting float to data type numeric (capped to 99.99)           
/****************************************************************************************************/


--uncomment to debug
/*
declare @CountryCode varchar(2)
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @CountryCode = 'AU', @DateRange = '_User Defined', @StartDate = '2018-06-01', @EndDate = '2018-06-30'
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
        @SubjectArea = 'SugarCRM Strike Rate',
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


if @DateRange = '_User Defined'
	select @rptStartDate = @StartDate, @rptEndDate = @EndDate
else
	select @rptStartDate = StartDate, @rptEndDate = EndDate
	from [db-au-ods].dbo.vDateRange
	where DateRange = @DateRange	



--get Outlet Unique Identifiers
if object_id('[db-au-stage].dbo.etl_scrmStrikeRateAccount') is not null drop table [db-au-stage].dbo.etl_scrmStrikeRateAccount

select @SQL = 'select * into [db-au-stage].dbo.etl_scrmStrikeRateAccount
			  from openquery([db-au-penguinsharp.aust.covermore.com.au], ''
				select
					td.CountryCode as CountryKey,
					to1.AlphaCode,
					td.CurrencyCode,
					tc.CompanyName				
				from
					[AU_PenguinSharp_Active].dbo.tblOutlet to1
					inner join [AU_PenguinSharp_Active].dbo.tblDomain td ON td.DomainId = to1.DomainId 
					inner join [AU_PenguinSharp_Active].dbo.tblCompany tc ON td.DomainId = tc.DomainId
				where	
					TD.COUNTRYCODE = ''''' + @CountryCode + ''''' and
					TC.CompanyName = ''''Covermore'''''

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


if object_id('[db-au-stage].dbo.etl_scrmStrikeRate') is not null drop table [db-au-stage].dbo.etl_scrmStrikeRate
--get financial target

/*
commenting and modifying
select @SQL = 'select * into [db-au-stage].dbo.etl_scrmStrikeRate
			   from openquery(ULDWH02,''select d.CurMonthStart as [Month], o.CountryCode, o.AlphaCode, sum(t.InternationalTravellersCount) as PolicyCount, 0 as TicketCount
												from [db-au-star].dbo.factPolicyTransaction t
													inner join [db-au-star].dbo.dimDomain dd on dd.DomainSK = t.DomainSK
													cross apply (select top 1 
																 ldo.Country CountryCode,
																 ldo.SuperGroupName,
																 ldo.AlphaCode
																from
																	[db-au-star].dbo.dimOutlet do
																	inner join [db-au-star].dbo.dimOutlet ldo on ldo.OutletSK = do.LatestOutletSK
																where do.OutletSK = t.OutletSK) o
													cross apply (select top 1 
																 dd.[Date],
																 dd.CurMonthStart
																from
																	[db-au-star].dbo.Dim_Date dd
																where dd.Date_SK = t.DateSK) d
												where d.[Date] >= ''''' + convert(varchar(10),@rptStartDate,120) + ''''' and d.[Date] < ''''' + convert(varchar(10),dateadd(d,1,@rptEndDate),120) + ''''' and
													o.CountryCode = ''''' + @CountryCode + ''''' and o.SuperGroupName = ''''Flight Centre''''
												group by d.CurMonthStart, o.CountryCode, o.AlphaCode
												
												union all

												select d.CurMonthStart as [Month], o.CountryCode, o.AlphaCode, 0 as PolicyCount, sum(t.TicketCount) as TicketCount
												from 
													[db-au-star].dbo.factTicket t
													inner join [db-au-star].dbo.dimDomain dd on	dd.DomainSK = t.DomainSK
													inner join [db-au-star].dbo.dimDestination org on org.DestinationSK = t.OriginSK and 
													org.Destination = case when dd.CountryCode = ''''AU'''' then ''''Australia''''
																			when dd.CountryCode = ''''NZ'''' then ''''New Zealand''''
																		end											
												cross apply (select top 1 ldo.Country CountryCode, ldo.SuperGroupName, ldo.AlphaCode
															from [db-au-star].dbo.dimOutlet do
																inner join [db-au-star].dbo.dimOutlet ldo on ldo.OutletSK = do.LatestOutletSK
															where do.OutletSK = t.OutletSK) o
												cross apply (select top 1 dd.[Date], dd.CurMonthStart
															from [db-au-star].dbo.Dim_Date dd
															where dd.Date_SK = t.DateSK) d
												where d.[Date] >= ''''' + convert(varchar(10),@rptStartDate,120) + ''''' and d.[Date] < ''''' + convert(varchar(10),dateadd(d,1,@rptEndDate),120) + ''''' and
													o.CountryCode = ''''' + @CountryCode  + ''''' and o.SuperGroupName = ''''Flight Centre''''
												group by d.CurMonthStart, o.CountryCode, o.AlphaCode '')'
*/

select @SQL = 'select d.CurMonthStart as [Month], o.CountryCode, o.AlphaCode, sum(t.InternationalTravellersCount) as PolicyCount, 0 as TicketCount
			   into [db-au-stage].dbo.etl_scrmStrikeRate
												from [db-au-star].dbo.factPolicyTransaction t
													inner join [db-au-star].dbo.dimDomain dd on dd.DomainSK = t.DomainSK
													cross apply (select top 1 
																 ldo.Country CountryCode,
																 ldo.SuperGroupName,
																 ldo.AlphaCode
																from
																	[db-au-star].dbo.dimOutlet do
																	inner join [db-au-star].dbo.dimOutlet ldo on ldo.OutletSK = do.LatestOutletSK
																where do.OutletSK = t.OutletSK) o
													cross apply (select top 1 
																 dd.[Date],
																 dd.CurMonthStart
																from
																	[db-au-star].dbo.Dim_Date dd
																where dd.Date_SK = t.DateSK) d
												where d.[Date] >= ''' + convert(varchar(10),@rptStartDate,120) + ''' and d.[Date] < ''' + convert(varchar(10),dateadd(d,1,@rptEndDate),120) + ''' and
													o.CountryCode = ''' + @CountryCode + ''' and o.SuperGroupName = ''Flight Centre''
												group by d.CurMonthStart, o.CountryCode, o.AlphaCode
												
												union all

												select d.CurMonthStart as [Month], o.CountryCode, o.AlphaCode, 0 as PolicyCount, sum(t.TicketCount) as TicketCount
												from 
													[db-au-star].dbo.factTicket t
													inner join [db-au-star].dbo.dimDomain dd on	dd.DomainSK = t.DomainSK
													inner join [db-au-star].dbo.dimDestination org on org.DestinationSK = t.OriginSK and 
													org.Destination = case when dd.CountryCode = ''AU'' then ''Australia''
																			when dd.CountryCode = ''NZ'' then ''New Zealand''
																		end											
												cross apply (select top 1 ldo.Country CountryCode, ldo.SuperGroupName, ldo.AlphaCode
															from [db-au-star].dbo.dimOutlet do
																inner join [db-au-star].dbo.dimOutlet ldo on ldo.OutletSK = do.LatestOutletSK
															where do.OutletSK = t.OutletSK) o
												cross apply (select top 1 dd.[Date], dd.CurMonthStart
															from [db-au-star].dbo.Dim_Date dd
															where dd.Date_SK = t.DateSK) d
												where d.[Date] >= ''' + convert(varchar(10),@rptStartDate,120) + ''' and d.[Date] < ''' + convert(varchar(10),dateadd(d,1,@rptEndDate),120) + ''' and
													o.CountryCode = ''' + @CountryCode  + ''' and o.SuperGroupName = ''Flight Centre''
												group by d.CurMonthStart, o.CountryCode, o.AlphaCode '

exec(@SQL)



if object_id('[db-au-stage].dbo.etl_scrmStrikeRateOut') is not null drop table [db-au-stage].dbo.etl_scrmStrikeRateOut
select
	o.CountryKey + '.' + case when o.CompanyName = 'Covermore' then 'CMA' else 'TIP' end + '.' + o.AlphaCode as [UniqueIdentifier],
	sr.[Month],
	case when sum(sr.TicketCount) = 0 then 0
         when (sum(convert(float,sr.PolicyCount)) / sum(convert(float,sr.TicketCount)) >= 100) then 99.99 -- To fix the Arithmetic overflow error converting float to data type numeric
			else convert(numeric(6,4),sum(convert(float,sr.PolicyCount)) / sum(convert(float,sr.TicketCount)))
	end as StrikeRate,
	getdate() as LoadDate,
	null as UpdateDate
into [db-au-stage].dbo.etl_scrmStrikeRateOut
from
	[db-au-stage].dbo.etl_scrmStrikeRateAccount o
	inner join [db-au-stage].dbo.etl_scrmStrikeRate sr on 
		o.CountryKey = sr.CountryCode collate database_default and
		o.AlphaCode = sr.AlphaCode collate database_default
group by
	o.CountryKey + '.' + case when o.CompanyName = 'Covermore' then 'CMA' else 'TIP' end + '.' + o.AlphaCode,
	sr.[Month]


if object_id('[db-au-ods].dbo.scrmStrikeRate') is null
begin
	create table [db-au-ods].dbo.scrmStrikeRate
	(
		BIRowID bigint not null identity(1,1),
		[UniqueIdentifier] varchar(50) null,
		[Month] date null,
		StrikeRate numeric(6,4) null,
		LoadDate datetime null,
		UpdateDate datetime null,
		isSynced nvarchar(1) NULL,
		SyncedDateTime datetime null
	)
    create clustered index idx_scrmStrikeRate_BIRowID on [db-au-ods].dbo.scrmStrikeRate(BIRowID)
    create nonclustered index idx_scrmStrikeRate_UniqueIdentifier on [db-au-ods].dbo.scrmStrikeRate([UniqueIdentifier]) include ([Month])
end

select @sourcecount = count(*)
from [dbo].[etl_scrmStrikeRateOut]


begin transaction
begin try

	delete a
	from
		[db-au-ods].dbo.scrmStrikeRate a
		inner join [db-au-stage].dbo.etl_scrmStrikeRateOut b on
			a.[UniqueIdentifier] = b.[UniqueIdentifier] collate database_default and
			a.[Month] = b.[Month] 


	insert into [db-au-ods].dbo.scrmStrikeRate with (tablockx)
	(
		[UniqueIdentifier],
		[Month],
		StrikeRate,
		LoadDate,
		UpdateDate,
		isSynced,
		SyncedDateTime
	)
	select
		[UniqueIdentifier],
		[Month],
		StrikeRate,
		LoadDate,
		UpdateDate,
		null as isSynced,
		null as SyncedDateTime
	from etl_scrmStrikeRateOut
	


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
