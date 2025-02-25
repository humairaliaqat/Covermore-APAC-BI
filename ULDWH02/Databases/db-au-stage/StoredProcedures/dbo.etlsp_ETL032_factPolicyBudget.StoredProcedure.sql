USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL032_factPolicyBudget]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL032_factPolicyBudget] 
    @FiscalYear varchar(4)

as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20131115
Prerequisite:   Requires Penguin Data Model ETL successfully run.
                Requires [db-au-cmdwh].dbo.penPolicy table available
Description:    factPolicyBudget dimension table contains Policy attributes.
Parameters:        @FiscalYear: Optional. if null, it will use current fiscal year
Change History:
                20131115 - LT - Procedure created
                20150204 - LS - replace batch codes with standard batch logging

*************************************************************************************************************************************/

--uncomment to debug
/*
declare @FiscalYear varchar(4)
select @FiscalYear = null
*/

    set nocount on

    declare
        @batchid int,
        @start date,
        @end date,
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

    end try
    
    begin catch
    
        --or manually
    
        set @batchid = -1
        
    end catch


    --get fiscal year
    if @FiscalYear = '' or @FiscalYear is null
        select 
            @FiscalYear = max(FiscalYear) 
        from 
            [db-au-stage].dbo.etl_excel_budget


    if object_id('[db-au-stage].dbo.etl_factPolicyBudgetTemp') is not null drop table [db-au-stage].dbo.etl_factPolicyBudgetTemp
    select
        d.[Date],
        case when b.Country = 'AU' then 7
             when b.Country = 'NZ' then 8
             when b.Country = 'SG' then 9
             when b.Country = 'MY' then 10
             when b.Country = 'UK' then 11
        end as DomainID,
        case when b.Country = 'AU' and b.Company = 'CM' then 'AU-CM7-' + b.AlphaCode
                 when b.Country = 'AU' and b.Company = 'TIP' then 'AU-TIP7-' + b.AlphaCode
                 when b.Country = 'NZ' then 'NZ-CM8-' + b.AlphaCode
                 when b.Country = 'SG' then 'SG-CM9-' + b.AlphaCode
                 when b.Country = 'MY' then 'MY-CM10-' + b.AlphaCode
                 when b.Country = 'UK' then 'UK-CM11-' + b.ALphaCode
        end OutletAlphaKey,
        b.BudgetAmount,
        a.AcceleratorAmount
    into [db-au-stage].dbo.etl_factPolicyBudgetTemp
    from
        [db-au-stage].dbo.etl_excel_budget b
        join [db-au-stage].dbo.etl_excel_accelerator a on
            b.[Days] = a.[Days] and
            b.[FiscalYear] = a.[FiscalYear] and
            b.[Country] = a.[Country] and
            b.[Company] = a.[Company] and
            b.[AlphaCode] = a.[AlphaCode]
        join [db-au-star].dbo.Dim_Date d on
            b.FiscalYear = d.Fiscal_Year and
            substring(b.[Days],5,len(b.[Days])) = d.Fiscal_Day_Of_Year
    where
        b.FiscalYear = @FiscalYear

    if object_id('[db-au-stage].dbo.etl_factPolicyBudget') is not null drop table [db-au-stage].dbo.etl_factPolicyBudget
    select
        d.Date_SK as DateSK,
        isnull(dm.DomainSK,-1) as DomainSK,
        isnull(o.OutletSK,-1) as OutletSK,
        b.BudgetAmount,
        b.AcceleratorAmount
    into [db-au-stage].dbo.etl_factPolicyBudget
    from
        [db-au-stage].dbo.etl_factPolicyBudgetTemp b
	    outer apply
	    (
		    select top 1 Date_SK
		    from [db-au-star].dbo.Dim_Date d
		    where b.[Date] = d.[Date]
	    ) d    
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
		    where isnull(b.OutletAlphaKey,'') = isnull(o.OutletAlphaKey,'') 
		    and b.[Date] between o.ValidStartDate and o.ValidEndDate
	    ) o       


    --create factPolicyBudget if table does not exist
    if object_id('[db-au-star].dbo.factPolicyBudget') is null
    begin
        create table [db-au-star].dbo.factPolicyBudget
        (
            DateSK int not null,
            DomainSK int not null,
            OutletSK int not null,
            BudgetAmount float null,
            AcceleratorAmount float null,
            LoadDate datetime not null,
            updateDate datetime null,
            LoadID int not null,
            updateID int null
        )
        create clustered index idx_factPolicyBudget_DateSK on [db-au-star].dbo.factPolicyBudget(DateSK,OutletSK)
    end
    
    select
        @sourcecount = count(*)
    from
        [db-au-stage].dbo.etl_factPolicyBudget

    begin transaction
    begin try
    
        delete [db-au-star].dbo.factPolicyBudget
        from
            [db-au-star].dbo.factPolicyBudget b
            join [db-au-stage].dbo.etl_factPolicyBudget a on
                b.DateSK = a.DateSK

        insert into [db-au-star].dbo.factPolicyBudget with (tablockx)
        (
            DateSK,
            DomainSK,
            OutletSK,
            BudgetAmount,
            AcceleratorAmount,
            LoadDate,
            updateDate,
            LoadID,
            updateID
        )
        select
            DateSK,
            DomainSK,
            OutletSK,
            BudgetAmount,
            AcceleratorAmount,
            getdate() as LoadDate,
            null as updateDate,
            @batchid as LoadID,
            null as updateID
        from
            [db-au-stage].dbo.etl_factPolicyBudget
            
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
