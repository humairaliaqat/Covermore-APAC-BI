USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL032_factFlightCentreTicket]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL032_factFlightCentreTicket] 
    @DateRange varchar(30),
    @StartDate varchar(10),
    @EndDate varchar(10)
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20131115
Prerequisite:   Requires Penguin Data Model ETL successfully run.

Description:    factFlightCentreTicket fact table contains flight centre ticket transactions.
Parameters:        @DateRange:    Required. Standard date range or _User Defined
                @StartDate:    Required if _User Defined. Format YYYY-MM-DD eg. 2013-01-01
                @EndDate:    Required if _User Defined. Format YYYY-MM-DD eg. 2013-01-01
Change History:
                20131115 - LT - Procedure created
                20140710 - PW - Null handling and type 2 Outlet dimension lookup
                20150204 - LS - replace batch codes with standard batch logging

*************************************************************************************************************************************/

--uncomment to debug
/*
declare @DateRange varchar(30)
declare @StartDate varchar(10)
declare @EndDate varchar(10)
select @DateRange = '_User Defined', @StartDate = '2011-07-01', @EndDate = '2999-12-31'
*/

    set nocount on

    declare
        @batchid int,
        @start date,
        @end date,
        @rptStartDate date,
        @rptEndDate date,
        @name varchar(50),
        @sourcecount int,
        @insertcount int,
        @updatecount int

    declare @mergeoutput table (MergeAction varchar(20))

    select
        @name = object_name(@@procid)

    begin try
    
        --check if this is running on batch

        exec syssp_getrunningbatch
            @SubjectArea = 'Policy Star',
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
                [db-au-cmdwh].dbo.vDateRange
            where 
                DateRange = @DateRange

    end catch



    if object_id('[db-au-stage].dbo.etl_factFlightCentreTicketTemp') is not null drop table [db-au-stage].dbo.etl_factFlightCentreTicketTemp
    select
        f.IssuedDate as IssueMonth,
        case when f.CountryKey = 'AU' then 7
             when f.CountryKey = 'NZ' then 8
             when f.CountryKey = 'SG' then 9
             when f.CountryKey = 'MY' then 10
             when f.CountryKey = 'UK' then 11
             else -1
        end as DomainID,
        isnull(f.OutletKey,'') OutletKey,
        isnull(f.OutletAlphaKey,'') OutletAlphaKey,
        isnull(f.FLTicketCountINT,0) as FLInternationalTicketCount,
        isnull(f.FLTicketCountDOM,0) as FLDomesticTicketCount,
        isnull(f.CMPolicyCountINT,0) as CMInternationalPolicyCount,
        isnull(f.CMPolicyCountDOM,0) as CMDomesticPolicyCount
    into [db-au-stage].dbo.etl_factFlightCentreTicketTemp
    from
        [db-au-cmdwh].dbo.usrFLTicketData f
    where
        f.IssuedDate between @rptStartDate and @rptEndDate


    if object_id('[db-au-stage].dbo.etl_factFlightCentreTicket') is not null drop table [db-au-stage].dbo.etl_factFlightCentreTicket
    select
        convert(varchar(8),b.IssueMonth,112) as DateSK,
        isnull(dm.DomainSK,-1) as DomainSK,
        isnull(o.OutletSK,-1) as OutletSK,
        b.FLInternationalTicketCount,
        b.FLDomesticTicketCount,
        b.CMInternationalPolicyCount,
        b.CMDomesticPolicyCount
    into [db-au-stage].dbo.etl_factFlightCentreTicket
    from
        [db-au-stage].dbo.etl_factFlightCentreTicketTemp b
        outer apply
	    (
		    select top 1 DomainSK
		    from [db-au-star].dbo.dimDomain dm
		    where b.DomainID = dm.DomainID
	    ) dm
        outer apply
	    (
		    select top 1 OutletSK
		    from [db-au-star].dbo.dimOutlet o
		    where b.OutletAlphaKey = o.OutletAlphaKey 
		    and b.IssueMonth between convert(varchar(8),o.ValidStartDate,112) and convert(varchar(8),o.ValidEndDate,112)
	    ) o    

    --create factPolicyBudget if table does not exist
    if object_id('[db-au-star].dbo.factFlightCentreTicket') is null
    begin
        create table [db-au-star].dbo.factFlightCentreTicket
        (
            DateSK int not null,
            DomainSK int not null,
            OutletSK int not null,
            FLInternationalTicketCount int null,
            FLDomesticTicketCount int null,
            CMInternationalPolicyCount int null,
            CMDomesticPolicyCount int null,
            LoadDate datetime not null,
            updateDate datetime null,
            LoadID int not null,
            updateID int null
        )
        create clustered index idx_factFlightCentreTicket_DateSK on [db-au-star].dbo.factFlightCentreTicket(DateSK,OutletSK)
    end
    
    
    select
        @sourcecount = count(*)
    from
        [db-au-stage].dbo.etl_factFlightCentreTicket

    begin transaction
    begin try
    
        delete [db-au-star].dbo.factFlightCentreTicket
        from
            [db-au-star].dbo.factFlightCentreTicket b
            join [db-au-stage].dbo.etl_factFlightCentreTicket a on
                b.DateSK = a.DateSK and
                b.OutletSK = a.OutletSK


        insert into [db-au-star].dbo.factFlightCentreTicket with (tablockx)
        (
            DateSK,
            DomainSK,
            OutletSK,
            FLInternationalTicketCount,
            FLDomesticTicketCount,
            CMInternationalPolicyCount,
            CMDomesticPolicyCount,
            LoadDate,
            updateDate,
            LoadID,
            updateID
        )
        select
            DateSK,
            DomainSK,
            OutletSK,
            FLInternationalTicketCount,
            FLDomesticTicketCount,
            CMInternationalPolicyCount,
            CMDomesticPolicyCount,
            getdate() as LoadDate,
            null as updateDate,
            @batchid as LoadID,
            null as updateID
        from
            [db-au-stage].dbo.etl_factFlightCentreTicket

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

end
GO
