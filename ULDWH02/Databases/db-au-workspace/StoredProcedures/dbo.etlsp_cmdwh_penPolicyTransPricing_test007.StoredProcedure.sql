USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPolicyTransPricing_test007]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE procedure [dbo].[etlsp_cmdwh_penPolicyTransPricing_test007]  
    @Country varchar(10) = 'AUNZSGMY',    --Required. AUNZSGMY, or UK, or US  
    @ReportingPeriod varchar(30),       --Required. Default value 'Last 30 Days'  
    @StartDate varchar(10),             --Optional. Format YYYY-MM-DD  
    @EndDate varchar(10)                --Optional. Format YYYY-MM-DD  
  
as  
begin  
  
/************************************************************************************************************************************  
Author:         Linus Tor  
Date:           20120209  
Prerequisite:   Requires Penguin ETL successfully transferred from  Penguin production database.  
Description:    This procedure transforms and summarises a number of transaction tables.  
                - penPolicyTransTax: holds taxes per policy transaction  
                - penPolicyTransTravellerPrice: holds traveller prices per policy transaction per traveller  
                - penPolicyTransPolicyPrice: holds policy prices per policy Transaction  
                - penPolicyTransTravellerAddOnPrice: holds traveller addon prices per policy transaction per addon  
                - tblPolicyTransEMCPrice: holds EMC prices per policy transaction  
                - penPolicyTransAddOn: holds addon gross premiums on transaction level  
  
Change History:  
                20120209 - LT - Procedure created  
                20120321 - LT - Amended pricing transaction summaries to ensure only distinct records are summed  
                20120629 - LS - Optimize index usage  
                20120701 - LS - optimize run time, use temporary table to remove redundant calls to penPolicyTransaction  
                20121101 - LS - add unadjusted taxes  
                20121107 - LS - refactoring & domain related changes  
                20130412 - LS - case 18432, summarise addon premium on transaction level to replace views  
                20130728 - LT - Add Country parameter to cater for UK ETL.  
                                Include Country filter in etl_penPolicyTransaction query  
                20130731 - LS - Set default value for Country so it doesn't break other process calling this  
                20130819 - LS - case 19018, critical bug found on penPolicyPrice, UK data causes duplicate data  
                                include countrykey in join condition  
                20131204 - LS - case 19524, stamp duty & gst bug, use new pricing calculation  
                                include TransactionDateTime in 'to process selection'  
                20131212 - LS - fix circular dependencies, change penPolicyTransSummary - > penPolicyTransaction  
                20140616 - LS - TFS 12416, Penguin 9.0 / China (Unicode)  
                                synced roll up  
                20140617 - LS - TFS 12416, schema and index cleanup  
                20140715 - LS - F 21325, use transaction, other session will not see data gets deleted until after it's replaced (intraday refresh)  
                20140725 - LS - F21428, sas data verification, use vpenPolicyPriceComponent instead duplicating code all over the place  
    20160321 - LT - Penguin 18.0, Added US penguin instance  
                20190122 - LL - performance related changes, materialise addon count, swith to optimised version of price component view  
  
*************************************************************************************************************************************/  
  
--uncomment to debug  
--declare @Country varchar(10)  
--declare @ReportingPeriod varchar(30)  
--declare @StartDate varchar(10)  
--declare @EndDate varchar(10)  
--select  
--    @Country = 'AUNZSGMY',  
--    @ReportingPeriod = '_User Defined',  
--    @StartDate = '2010-01-01',  
--    @EndDate = '2012-03-20'  
  
  
    set nocount on  
  
    declare @rptStartDate datetime  
    declare @rptEndDate datetime  
  
    /* get reporting dates */  
    if @ReportingPeriod = '_User Defined'  
        select  
            @rptStartDate = convert(smalldatetime,@StartDate),  
            @rptEndDate = convert(smalldatetime,@EndDate)  
  
    else  
        select  
            @rptStartDate = StartDate,  
            @rptEndDate = EndDate  
        from  
            [db-au-cmdwh].dbo.vDateRange  
        where  
            DateRange = @ReportingPeriod  
  
  
    --populate temp table with country values  
    if object_id('tempdb..#Country') is null  
        create table #Country (Country varchar(2) null)  
    else  
        truncate table #Country  
  
    if @Country = 'UK'  
        insert #Country values('UK')  
    else if @Country = 'US'  
  insert #Country values('US')  
 else  
    begin  
        insert #Country values('AU')  
        insert #Country values('NZ')  
        insert #Country values('SG')  
        insert #Country values('MY')  
  insert #Country values('CN')  
  insert #Country values('ID')  
  insert #Country values('IN')  
    end  
  
    /* synced rollup */  
    if object_id('etl_penPolicyTransaction_sync') is null  
        create table etl_penPolicyTransaction_sync  
        (  
            PolicyTransactionKey varchar(41) null  
        )  
  
    if exists (select null from etl_penPolicyTransaction_sync where PolicyTransactionKey is not null)  
    begin  
  
        if object_id('[db-au-workspace]..etl_penPolicyTransAddon') is not null  
            drop table [db-au-workspace]..etl_penPolicyTransAddon  
  
        select  
            pt.PolicyKey,  
            pt.PolicyTransactionKey,  
            pt.CountryKey,  
            pt.CompanyKey,  
            pt.TransactionType,  
            pt.TransactionStatus  
        into  
            [db-au-workspace]..etl_penPolicyTransAddon  
        from  
            [db-au-cmdwh].dbo.penPolicyTransaction pt  
        where  
            pt.PolicyTransactionKey in  
            (  
                select  
                    PolicyTransactionKey  
                from  
                    etl_penPolicyTransaction_sync  
            )  
  
    end  
  
    else  
    /* dump records in date range */  
    begin  
  
        if object_id('[db-au-workspace]..etl_penPolicyTransAddon') is not null  
            drop table [db-au-workspace]..etl_penPolicyTransAddon  
  
        select  
            pt.PolicyKey,  
            pt.PolicyTransactionKey,  
            pt.CountryKey,  
            pt.CompanyKey,  
            pt.TransactionType,  
            pt.TransactionStatus  
        into  
            [db-au-workspace]..etl_penPolicyTransAddon  
        from  
            [db-au-cmdwh].dbo.penPolicyTransaction pt  
        where  
            CountryKey in (select Country from #Country) AND  
            (  
                (  
                    pt.IssueDate >= @StartDate and  
                    pt.IssueDate <  dateadd(day, 1, @EndDate)  
                ) or  
                (  
                    pt.PaymentDate >= @StartDate and  
                    pt.PaymentDate <  dateadd(day, 1, @EndDate)  
                ) or  
                (  
                    TransactionDateTime >= @StartDate and  
                    TransactionDateTime <  dateadd(day, 1, @EndDate)  
                )  
            )  
  
    end  
  
    create index idx on [db-au-workspace]..etl_penPolicyTransAddon(PolicyTransactionKey) include (CountryKey, CompanyKey)  
  
  
    /* all penPolicyTrans tables removed */  
  
    /******************************/  
    --PolicyTransAddOn  
    /******************************/  
    if object_id('[db-au-workspace]..penPolicyTransAddon_test007') is null  
    begin  
  
        create table [db-au-workspace]..penPolicyTransAddon_test007  
        (  
            [BIrowID] bigint not null identity(1,1),  
            [CountryKey] varchar(2) null,  
            [CompanyKey] varchar(5) null,  
            [PolicyTransactionKey] varchar(41) null,  
            [AddOnGroup] nvarchar(50) null,  
            [AddOnText] nvarchar(500) null,  
            [CoverIncrease] money null,  
            [GrossPremium] money null,  
            [UnAdjGrossPremium] money null,  
            [AddonCount] int,  
            [PolicyKey] varchar(41) null,
		    [Commission]  money null   
        )  
        
        create clustered index idx_penPolicyTransAddOn_BIRowID on [db-au-workspace]..penPolicyTransAddon_test007(BIRowID)  
        create nonclustered index idx_penPolicyTransAddOn_AddOnPrice on [db-au-workspace]..penPolicyTransAddon_test007(PolicyTransactionKey,AddonGroup) include (GrossPremium,UnAdjGrossPremium,AddOnCount)  
        create nonclustered index idx_penPolicyTransAddOn_PolicyKey on [db-au-workspace]..penPolicyTransAddon_test007(PolicyKey,AddonGroup) include (PolicyTransactionKey,GrossPremium,UnAdjGrossPremium,AddOnCount)  
  
    end  
  
    if object_id('tempdb..#penPolicyTransAddOn') is not null  
        drop table #penPolicyTransAddOn  
  
    select  
        pt.CountryKey,  
        pt.CompanyKey,  
        pt.PolicyKey,  
        t.PolicyTransactionKey,  
        case  
            when t.PriceCategory = 'EMC' then 'Medical'  
            else t.PriceCategory  
        end AddOnGroup,  
        t.AddOnText,  
        t.CoverIncrease,  
        sum(t.GrossPremiumAfterDiscount) GrossPremium,  
        sum(t.GrossPremiumBeforeDiscount) UnAdjGrossPremium,  
        max(pt.TransactionStatus) TransactionStatus,  
        max(pt.TransactionType) TransactionType,
		sum (CommissionAfterdiscount+GrossAdminFeeAfterDiscount ) as [Commission]       
    into #penPolicyTransAddOn  
    from  
        [db-au-cmdwh]..vpenPolicyPriceComponentOptimise t  
        inner join [db-au-workspace]..etl_penPolicyTransAddon pt on  
            pt.PolicyTransactionKey = t.PolicyTransactionKey  
    where  
        t.PriceCategory <> 'Base Rate'  
    group by  
        pt.CountryKey,  
        pt.CompanyKey,  
        pt.PolicyKey,  
        t.PolicyTransactionKey,  
        PriceCategory,  
        AddOnText,  
        CoverIncrease  
  
    alter table #penPolicyTransAddOn add Idx bigint not null identity(1,1)  
  
  
    begin transaction penPolicyTransAddOn_workspace  
  
    begin try  
  
        delete [db-au-workspace]..penPolicyTransAddon_test007  
        where  
            PolicyTransactionKey in  
            (  
                select distinct  
                    PolicyTransactionKey  
                from  
                    [db-au-workspace]..etl_penPolicyTransAddon  
            )  
  
        insert into [db-au-workspace]..penPolicyTransAddon_test007 with(tablockx)  
        (  
            CountryKey,  
            CompanyKey,  
            PolicyKey,  
            PolicyTransactionKey,  
            AddOnGroup,  
            AddOnText,  
            CoverIncrease,  
            GrossPremium,  
            UnAdjGrossPremium,  
            AddOnCount,
			Commission  
        )  
        select  
            CountryKey,  
            CompanyKey,  
            PolicyKey,  
            PolicyTransactionKey,  
            AddOnGroup,  
            AddOnText,  
            CoverIncrease,  
            GrossPremium,  
            UnAdjGrossPremium,  
            case  
                when TransactionType in ('Extend', 'Upgrade AMT Max Trip Duration', 'Partial Refund') then 0  
                when TransactionStatus = 'Active' then 1  
                else -1  
            end   
            --*  
            --case  
            --    when idx = min(idx) over (partition by PolicyTransactionKey,AddOnGroup) and GrossPremium <> 0 then 1  
            --    else 0  
            --end   
            AddonCount,
			Commission  
        from  
            #penPolicyTransAddOn  
  
    end try  
  
    begin catch  
  
        if @@trancount > 0  
            rollback transaction penPolicyTransAddOn_workspace  
  
      --  exec syssp_genericerrorhandler 'penPolicyTransAddOn data refresh failed'  
  
    end catch  
  
    if @@trancount > 0  
        commit transaction penPolicyTransAddOn_workspace  
  
  
    if object_id('tempdb..#penPolicyTransAddOn') is not null  
        drop table #penPolicyTransAddOn  
  
    if object_id('[db-au-workspace]..etl_penPolicyTransAddon') is not null  
        drop table [db-au-workspace]..etl_penPolicyTransAddon  
  
    if object_id('tempdb..#Country') is not null  
        drop table #Country  
  
end  
  
  
  
GO
