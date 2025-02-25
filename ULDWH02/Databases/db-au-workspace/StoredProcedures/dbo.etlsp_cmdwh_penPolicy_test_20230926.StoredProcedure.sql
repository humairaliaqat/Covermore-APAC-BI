USE [db-au-workspace]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPolicy_test_20230926]    Script Date: 24/02/2025 5:22:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
    
    
CREATE procedure [dbo].[etlsp_cmdwh_penPolicy_test_20230926]    
as    
begin    
    
    
/************************************************************************************************************************************    
Author:         Linus Tor    
Date:           20120127    
Prerequisite:   Requires Penguin Data Model ETL successfully run.    
Description:    Policy table contains policy header attributes.    
                This transformation adds essential key fields    
Change History:    
                20120127 - LT - Procedure created    
                20120724 - LS - Add AreaType & PurchasePath    
                                Refactoring    
                20120911 - LS - Add IsShowDiscount    
                20121101 - LS - Add External Reference    
                20121107 - LS - refactoring & domain related changes    
                20130201 - LT - Fixed Area Type to read from tblArea instead of basing on Plan Codes    
                20130430 - LT - Added AreaNumber column    
                20130617 - LS - TFS 7664/8556/8557, UK Penguin    
                20130816 - LT - Added an Update statement to fix where AreaType is STILL null even after referencing tblArea.    
                20130820 - LT - Added isTripsPolicy flag to denote trips or penguin policy. default should be 0    
                20131024 - LT - Added ImportDate to penPolicy table    
                20131205 - LS - (ref: case 19524), change OutletSKey update statement    
                20131218 - LT - Found bugs with OutletSKey update statement. Reverting back to old method.    
                20140220 - LS - add policy competitor ETL    
                20140612 - LS - TFS 12416, Penguin 9.0 / China (Unicode)    
                20140617 - LS - TFS 12416, schema and index cleanup    
                20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data    
                20140715 - LS - F 21325, use transaction, other session will not see data gets deleted until after it's replaced (intraday refresh)    
                20140805 - LT - TFS 13021, changed PolicyNumber from bigint to varchar(50), changed PolicyNoKey from varchar(41) to varchar(100)    
                20150311 - LT - Penguin 12.5, added TaxInvoiceNumber column to penPolicy    
                20150601 - LS - bug preventation on TaxInvoiceNumber, key values can be more than 1, limit it to specific type    
                20150918 - LS - bug work around, duplicate policydetails, TIP 1620907    
                20151027 - DM - Penguin v16 Release - update column PrimaryCountry    
                20151119 - LT - Penguin 16.5 Release - Added penPolicyDestination_test table and set penPolicy.PrimaryCountry to destination with    
                                highest risk based on area weighting. Added MultiDestination column to penPolicy. This is unmodified PrimaryCountry field in Penguin source.    
                20160321 - LT - Penguin 18.0, Added US Penguin instance. Added FinanceProductID, FinanceProductCode, FinanceProductName columns to penPolicy    
                20160519 - LT - TFS 24689, removed leading space in PrimaryCountry and MultiDestination columns    
                20161021 - LS - Penguin 20.0, InitialDepositDate    
    20170419 - LT - Penguin 24.0, increased AreaName to nvarchar(100)    
    20170703 - VL - Update sp for AreaName data type change    
    20181107 - LT - Added PlanCode column    
    20190319 - RS - penPolicy.ExternalReference column width increased from 50 to 100    
 20210306, SS, CHG0034615 Add filter for BK.com  
 20230606 - Added New Column ExternalReference1 to store LINKID information  
*************************************************************************************************************************************/    
    
    set nocount on    
    
    /* staging index */    
   --exec etlsp_StagingIndex_Penguin    
    
    
    --transform and load penPolicyDestination_test    
    if object_id('etl_penPolicy_testDestination_test') is not null drop table etl_penPolicy_testDestination_test    
    
    select     
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        PrefixKey + convert(varchar, p.PolicyID) PolicyKey,    
        ltrim(rtrim(p.PrimaryCountry)) as PrimaryCountry,    
        p.Area,    
        p.AreaCode,    
        d.ItemNumber as DestinationOrder,    
        ltrim(rtrim(d.Item)) as Destination,    
        area.CountryAreaID,    
        area.CountryID,    
        area.AreaID,            
        area.Weighting    
    into etl_penPolicy_testDestination_test    
    from    
        [db-au-stage].dbo.penguin_tblPolicy_aucm p    
        inner join [db-au-stage].dbo.penguin_tblPolicyDetails_aucm pd on p.PolicyID = pd.PolicyID    
        outer apply [db-au-stage].dbo.fn_DelimitedSplit8K(p.PrimaryCountry,';') d    
        cross apply [db-au-stage].dbo.fn_GetDomainKeys(p.DomainId, 'CM', 'AU') dk      
        outer apply    
        (    
            select top 1    
                ca.CountryAreaID,    
                ca.CountryID,    
                ca.AreaID,    
                a.Weighting    
            from    
                [db-au-stage].dbo.Penguin_tblCountryArea_aucm ca    
                inner join [db-au-stage].dbo.Penguin_tblCountry_aucm c on    
                    ca.CountryID = c.CountryID    
                inner join [db-au-stage].dbo.penguin_tblArea_aucm a on    
                    ca.AreaID = a.AreaId    
            where    
                a.DomainID = p.DomainId and    
                a.Area collate database_default  = p.Area collate database_default  and    
                c.Country collate database_default  = d.Item collate database_default     
        ) area    
        
    union all    
    
    select     
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        PrefixKey + convert(varchar, p.PolicyID) PolicyKey,    
        ltrim(rtrim(p.PrimaryCountry)) as PrimaryCountry,    
        p.Area,    
        p.AreaCode,    
        d.ItemNumber as DestinationOrder,    
        ltrim(rtrim(d.Item)) as Destination,    
        area.CountryAreaID,    
        area.CountryID,    
        area.AreaID,            
        area.Weighting    
    from    
        [db-au-stage].dbo.penguin_tblPolicy_autp p    
        inner join [db-au-stage].dbo.penguin_tblPolicyDetails_autp pd on p.PolicyID = pd.PolicyID    
        outer apply [db-au-stage].dbo.fn_DelimitedSplit8K(p.PrimaryCountry,';') d    
        cross apply [db-au-stage].dbo.fn_GetDomainKeys(p.DomainId, 'TIP', 'AU') dk      
        outer apply    
        (    
            select top 1    
                ca.CountryAreaID,    
                ca.CountryID,    
                ca.AreaID,    
                a.Weighting    
            from    
                [db-au-stage].dbo.Penguin_tblCountryArea_autp ca    
                inner join [db-au-stage].dbo.Penguin_tblCountry_autp c on    
                    ca.CountryID = c.CountryID    
                inner join [db-au-stage].dbo.penguin_tblArea_autp a on    
                    ca.AreaID = a.AreaId    
            where    
                a.DomainID = p.DomainId and    
                a.Area collate database_default  = p.Area collate database_default  and    
                c.Country collate database_default  = d.Item collate database_default     
        ) area    
            
    union all    
    
    select     
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        PrefixKey + convert(varchar, p.PolicyID) PolicyKey,    
        ltrim(rtrim(p.PrimaryCountry)) as PrimaryCountry,    
        p.Area,    
        p.AreaCode,    
        d.ItemNumber as DestinationOrder,    
        ltrim(rtrim(d.Item)) as Destination,    
        area.CountryAreaID,    
        area.CountryID,    
        area.AreaID,            
        area.Weighting    
    from    
        [db-au-stage].dbo.penguin_tblPolicy_ukcm p    
        inner join [db-au-stage].dbo.penguin_tblPolicyDetails_ukcm pd on p.PolicyID = pd.PolicyID    
        outer apply [db-au-stage].dbo.fn_DelimitedSplit8K(p.PrimaryCountry,';') d    
        cross apply [db-au-stage].dbo.fn_GetDomainKeys(p.DomainId, 'CM', 'UK') dk      
        outer apply    
        (    
            select top 1    
                ca.CountryAreaID,    
                ca.CountryID,    
				ca.AreaID,    
                a.Weighting    
            from    
                [db-au-stage].dbo.Penguin_tblCountryArea_ukcm ca    
                inner join [db-au-stage].dbo.Penguin_tblCountry_ukcm c on    
                    ca.CountryID = c.CountryID    
                inner join [db-au-stage].dbo.penguin_tblArea_ukcm a on    
                    ca.AreaID = a.AreaId    
            where    
                a.DomainID = p.DomainId and    
                a.Area collate database_default  = p.Area collate database_default  and    
                c.Country collate database_default  = d.Item collate database_default     
        ) area                
    
    union all    
    
    select     
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        PrefixKey + convert(varchar, p.PolicyID) PolicyKey,    
        ltrim(rtrim(p.PrimaryCountry)) as PrimaryCountry,    
        p.Area,    
        p.AreaCode,    
        d.ItemNumber as DestinationOrder,    
        ltrim(rtrim(d.Item)) as Destination,    
        area.CountryAreaID,    
        area.CountryID,    
        area.AreaID,            
        area.Weighting    
    from    
        [db-au-stage].dbo.penguin_tblPolicy_uscm p    
        inner join [db-au-stage].dbo.penguin_tblPolicyDetails_uscm pd on p.PolicyID = pd.PolicyID    
        outer apply [db-au-stage].dbo.fn_DelimitedSplit8K(p.PrimaryCountry,';') d    
        cross apply [db-au-stage].dbo.fn_GetDomainKeys(p.DomainId, 'CM', 'US') dk      
        outer apply    
        (    
            select top 1    
                ca.CountryAreaID,    
                ca.CountryID,    
                ca.AreaID,    
                a.Weighting    
            from    
                [db-au-stage].dbo.Penguin_tblCountryArea_uscm ca    
                inner join [db-au-stage].dbo.Penguin_tblCountry_uscm c on    
                    ca.CountryID = c.CountryID    
                inner join [db-au-stage].dbo.penguin_tblArea_uscm a on    
                    ca.AreaID = a.AreaId    
            where    
                a.DomainID = p.DomainId and    
                a.Area collate database_default  = p.Area collate database_default  and    
                c.Country collate database_default  = d.Item collate database_default     
        ) area            
    
    
    if object_id('[db-au-workspace].dbo.penPolicyDestination_test') is null    
    begin    
        create table [db-au-workspace].dbo.penPolicyDestination_test    
        (    
            CountryKey varchar(2) NOT NULL,    
            CompanyKey varchar(5) NOT NULL,    
            DomainKey varchar(41) NOT NULL,    
            PolicyKey varchar(71) NOT NULL,    
            PrimaryCountry nvarchar(max) NULL,    
            DestinationOrder bigint NULL,    
            Destination nvarchar(100) NULL,    
            Area nvarchar(100) NULL,    
            CountryAreaID int NULL,    
            CountryID int NULL,    
            AreaID int NULL,    
            Weighting int NULL,    
            isPrimaryDestination bit NULL    
        )    
        create clustered index idx_penPolicyDestination_test_PolicyKey on [db-au-workspace].dbo.penPolicyDestination_test(PolicyKey)    
        create nonclustered index idx_penPolicyDestination_test_Destination on [db-au-workspace].dbo.penPolicyDestination_test(Destination)    
        create nonclustered index idx_penPolicyDestination_test_isPrimaryCountry on [db-au-workspace].dbo.penPolicyDestination_test(isPrimaryDestination)    
    end    
    
    
    /*************************************************************/    
    -- Transfer data from  etl_penPolicy_testDestination_test to [db-au-cmdwh].dbo.penPolicyDestination_test    
    /*************************************************************/    
    begin transaction penPolicyDestination_test    
    
    begin try    
    
        delete a    
        from    
            [db-au-workspace].dbo.penPolicyDestination_test a    
            inner join etl_penPolicy_testDestination_test b on    
                b.PolicyKey = a.PolicyKey    
    
    
        insert [db-au-workspace].dbo.penPolicyDestination_test with(tablockx)    
        (    
            CountryKey,    
            CompanyKey,    
            DomainKey,    
            PolicyKey,    
            PrimaryCountry,    
           DestinationOrder,    
            Destination,    
            Area,    
            CountryAreaID,    
            CountryID,    
            AreaID,    
            Weighting,    
            isPrimaryDestination    
        )    
        select    
            d.CountryKey,    
            d.CompanyKey,    
            d.DomainKey,    
            d.PolicyKey,    
            d.PrimaryCountry,    
            d.DestinationOrder,    
            d.Destination,    
            d.Area,    
            d.CountryAreaID,    
            d.CountryID,    
            d.AreaID,    
            d.Weighting,    
            case when d.Destination = pr.Destination then 1 else 0 end isPrimaryDestination    
  from    
            etl_penPolicy_testDestination_test d    
            outer apply                                                --determine Destination has riskiest weighting    
            (                                                        --if there are multiple destinations of same area, the first destination (in ascending order) is selected    
                select top 1 Destination    
                from etl_penPolicy_testDestination_test    
                where    
                    PolicyKey = d.PolicyKey and    
                    AreaID = d.AreaID    
                order by AreaID, Weighting desc, Destination                        
            ) pr    
        order by d.PolicyKey    
    
    end try    
    
    begin catch    
    
        if @@trancount > 0    
            rollback transaction penPolicyDestination_test    
    
       -- exec syssp_genericerrorhandler 'penPolicyDestination_test data refresh failed'    
    
    end catch    
    
    if @@trancount > 0    
        commit transaction penPolicyDestination_test    
    
    
    
    if object_id('etl_penPolicy_test') is not null    
        drop table etl_penPolicy_test    
    
    select    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        PrefixKey + ltrim(rtrim(p.AlphaCode)) collate database_default OutletAlphaKey,    
        convert(bigint,null) as OutletSKey,    
        PrefixKey + convert(varchar, p.PolicyID) PolicyKey,    
        PrefixKey + convert(varchar, p.PolicyNumber collate database_default) PolicyNoKey,    
        DomainID,    
        p.PolicyID,    
        p.PolicyNumber collate database_default PolicyNumber,    
        p.AlphaCode as AlphaCode,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.IssueDate, TimeZone) IssueDate,    
        convert(date, [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.IssueDate, TimeZone)) IssueDateNoTime,    
        p.IssueDate IssueDateUTC,    
        convert(date, p.IssueDate) IssueDateNoTimeUTC,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.CancelledDate, TimeZone) CancelledDate,    
        p.PolicyStatus as StatusCode,    
        ps.StatusDescription,    
        p.Area,    
        ar.AreaType,    
        p.PrimaryCountry,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.TripStart, TimeZone) TripStart,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.TripEnd, TimeZone) TripEnd,    
        p.AffiliateReference,    
        p.HowDidYouHear,    
        p.AffiliateComments,    
        p.GroupName,    
        p.CompanyName,    
        '' PolicyType,    
        p.isCancellation,    
        pd.ProductID,    
        pp.ProductCode,    
        pp.ProductName,    
        pp.ProductDisplayName,    
        pp.PurchasePath,    
        pd.UniquePlanID,    
        pd.Excess,    
        pd.AreaName,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(pd.PolicyStart, TimeZone) PolicyStart,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(pd.PolicyEnd, TimeZone) PolicyEnd,    
        pd.DaysCovered,    
        pd.MaxDuration,    
        pd.PlanName,    
        pd.PlanType as TripType,    
        pd.PlanID,    
        pl.PlanDisplayName,    
        tc.TripCost as CancellationCover,    
        tc.TripCost,    
        pd.TripDuration,    
        pd.EmailConsent,    
        pd.ShowDiscount IsShowDiscount,    
        p.ExternalReference,  
  p.ExternalReference1 collate database_default ExternalReference1,  
        ar.AreaNumber,    
        ppi.ImportDate,    
        p.PreviousPolicyNumber collate database_default PreviousPolicyNumber,    
        p.CurrencyCode,    
        p.CultureCode,    
        p.AreaCode,    
        left(ptax.Value,50) collate database_default as TaxInvoiceNumber,    
        p.PrimaryCountry as MultiDestination,    
        fp.FinanceProductID,    
        case when ar.AreaType = 'International' then 'I' + fp.FinanceProductCode    
             when ar.AreaType = 'Domestic' then 'D' + fp.FinanceProductCode    
             when ar.AreaType = 'Domestic (Inbound)' then 'DI' + fp.FinanceProductCode    
             else 'I' + fp.FinanceProductCode    
             --else 'Unknown'    
        end as FinanceProductCode,    
        fp.FinanceProductName,    
        p.InitialDepositDate,    
  pl.PlanCode    
    into etl_penPolicy_test    
    from    
        [db-au-stage].dbo.Penguin_tblpolicy_aucm p    
        cross apply [db-au-stage].dbo.fn_GetDomainKeys(p.DomainId, 'CM', 'AU') dk    
        cross apply    
        (    
            select top 1     
                pd.*    
            from    
                [db-au-stage].dbo.penguin_tblPolicyDetails_aucm pd     
            where    
                p.PolicyID = pd.PolicyID    
        ) pd    
        outer apply    
        (    
            select top 1 Value                                    --Tax Invoice Number    
            from    
                [db-au-stage].dbo.penguin_tblPolicyKeyValues_aucm pkv    
                inner join [db-au-stage].dbo.penguin_tblPolicyKeyValueTypes_aucm pkt on     
                    pkv.TypeID = pkt.ID    
            where    
                PolicyID = p.PolicyID and    
                pkt.DomainID = p.DomainID and    
                pkt.Code = 'TAXINVOICENO'    
    
        ) ptax    
        outer apply    
        (    
            select top 1    
                StatusDescription    
            from    
                [db-au-stage].dbo.penguin_tblPolicyStatus_aucm    
            where    
                ID = p.PolicyStatus    
        ) ps    
        outer apply    
        (    
            select top 1    
                ProductCode,    
                ProductName,    
                ProductDisplayName,    
                rv.Value PurchasePath    
            from    
                [db-au-stage].dbo.penguin_tblProduct_aucm pp    
                inner join [db-au-stage].dbo.penguin_tblReferenceValue_aucm rv on    
                    rv.ID = pp.PurchasePathID    
            where    
                pp.ProductID = pd.ProductID    
        ) pp    
        outer apply    
        (    
            select top 1    
                DisplayName PlanDisplayName,    
                PlanName,    
                FinanceProductID,    
    PlanCode    
            from    
                [db-au-stage].dbo.penguin_tblPlan_aucm pl    
            where    
                pl.UniquePlanID = pd.UniquePlanID    
        ) pl    
        outer apply    
        (    
            select top 1    
                TripCost    
            from    
                [db-au-stage].dbo.penguin_tblPolicyTransaction_aucm tc    
            where    
                tc.PolicyID = p.PolicyID    
        ) tc    
        outer apply    
        (    
            select top 1    
                FinanceProductID,    
                Code as FinanceProductCode,    
                Name as FinanceProductName    
            from    
                [db-au-stage].dbo.penguin_tblFinanceProduct_aucm    
            where    
                FinanceProductID = pl.FinanceProductID    
        ) fp            
        outer apply    
        (    
            select top 1    
                case    
                    when ar.Area like '%inbound%' then 'Domestic (Inbound)'    
                    when ar.Domestic = 1 then 'Domestic'    
                    when ar.Domestic = 0 then 'International'    
                    else 'Unknown'    
                end as AreaType,    
                'Area ' + cast(ar.Weighting as varchar) as AreaNumber    
            from    
                [db-au-stage].dbo.penguin_tblPlan_aucm pl    
                inner join [db-au-stage].dbo.penguin_tblPlanArea_aucm pa on    
                    pl.PlanID = pa.PlanID    
                inner join [db-au-stage].dbo.penguin_tblArea_aucm ar on    
                    pa.AreaID = ar.AreaID and    
                    ar.Area = p.Area and    
                    ar.DomainID = p.DomainID    
            where    
                pl.UniquePlanID = pd.UniquePlanID    
        ) ar    
        outer apply    
        (    
            select    
                convert(date, max(CreateDateTime)) ImportDate    
            from    
                [db-au-cmdwh].dbo.penPolicyImport ppi    
            where    
                ppi.Status = 'DONE' and    
                ppi.CountryKey = 'AU' and    
                ppi.PolicyNumber collate database_default  = p.PolicyNumber collate database_default    
        ) ppi    
    
    union all    
    
    select    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        PrefixKey + ltrim(rtrim(p.AlphaCode)) collate database_default OutletAlphaKey,    
        convert(bigint,null) as OutletSKey,    
        PrefixKey + convert(varchar, p.PolicyID) PolicyKey,    
        PrefixKey + convert(varchar, p.PolicyNumber collate database_default) PolicyNoKey,    
        DomainID,    
        p.PolicyID,    
        p.PolicyNumber collate database_default PolicyNumber,    
        p.AlphaCode as AlphaCode,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.IssueDate, TimeZone) IssueDate,    
        convert(date, [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.IssueDate, TimeZone)) IssueDateNoTime,    
        p.IssueDate IssueDateUTC,    
        convert(date, p.IssueDate) IssueDateNoTimeUTC,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.CancelledDate, TimeZone) CancelledDate,    
        p.PolicyStatus as StatusCode,    
        ps.StatusDescription,    
        p.Area,    
        ar.AreaType,    
        p.PrimaryCountry,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.TripStart, TimeZone) TripStart,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.TripEnd, TimeZone) TripEnd,    
        p.AffiliateReference,    
        p.HowDidYouHear,    
        p.AffiliateComments,    
        p.GroupName,    
        p.CompanyName,    
        '' PolicyType,    
        p.isCancellation,    
        pd.ProductID,    
        pp.ProductCode,    
        pp.ProductName,    
        pp.ProductDisplayName,    
        pp.PurchasePath,    
        pd.UniquePlanID,    
        pd.Excess,    
        pd.AreaName,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(pd.PolicyStart, TimeZone) PolicyStart,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(pd.PolicyEnd, TimeZone) PolicyEnd,    
        pd.DaysCovered,    
        pd.MaxDuration,    
        pd.PlanName,    
        pd.PlanType as TripType,    
        pd.PlanID,    
        pl.PlanDisplayName,    
        tc.TripCost as CancellationCover,    
        tc.TripCost,    
        pd.TripDuration,    
        pd.EmailConsent,    
        pd.ShowDiscount IsShowDiscount,    
        p.ExternalReference,  
  p.ExternalReference1,  
        ar.AreaNumber,    
        ppi.ImportDate,    
        p.PreviousPolicyNumber collate database_default PreviousPolicyNumber,    
        p.CurrencyCode,    
        p.CultureCode,    
        p.AreaCode,    
        left(ptax.Value,50) collate database_default as TaxInvoiceNumber,    
        p.PrimaryCountry as MultiDestination,    
        fp.FinanceProductID,    
        case when ar.AreaType = 'International' then 'I' + fp.FinanceProductCode    
             when ar.AreaType = 'Domestic' then 'D' + fp.FinanceProductCode    
             when ar.AreaType = 'Domestic (Inbound)' then 'DI' + fp.FinanceProductCode    
             else 'Unknown'    
        end as FinanceProductCode,    
        fp.FinanceProductName,    
        p.InitialDepositDate,    
  pl.PlanCode    
    from    
        [db-au-stage].dbo.Penguin_tblpolicy_autp p    
        cross apply [db-au-stage].dbo.fn_GetDomainKeys(p.DomainId, 'TIP', 'AU') dk    
        cross apply    
        (    
            select top 1     
                pd.*    
            from    
                [db-au-stage].dbo.Penguin_tblPolicyDetails_autp pd     
            where    
                p.PolicyID = pd.PolicyID    
        ) pd    
        outer apply    
        (    
            select top 1 Value                                    --Tax Invoice Number    
            from    
                [db-au-stage].dbo.penguin_tblPolicyKeyValues_autp pkv    
                inner join [db-au-stage].dbo.penguin_tblPolicyKeyValueTypes_autp pkt on     
                    pkv.TypeID = pkt.ID    
            where    
                PolicyID = p.PolicyID and    
                pkt.DomainID = p.DomainID and    
                pkt.Code = 'TAXINVOICENO'    
    
        ) ptax    
        outer apply    
        (    
            select top 1    
                StatusDescription    
            from    
                [db-au-stage].dbo.penguin_tblPolicyStatus_autp    
            where    
                ID = p.PolicyStatus    
        ) ps    
        outer apply    
        (    
            select top 1    
                ProductCode,    
                ProductName,    
                ProductDisplayName,    
                rv.Value PurchasePath    
            from    
                [db-au-stage].dbo.penguin_tblProduct_autp pp    
                inner join [db-au-stage].dbo.penguin_tblReferenceValue_autp rv on    
                    rv.ID = pp.PurchasePathID    
            where    
                pp.ProductID = pd.ProductID    
        ) pp    
        outer apply    
        (    
            select top 1    
                DisplayName PlanDisplayName,    
                PlanName,    
                FinanceProductId,    
    PlanCode    
            from    
                [db-au-stage].dbo.penguin_tblPlan_autp pl    
            where    
                pl.UniquePlanID = pd.UniquePlanID    
        ) pl    
        outer apply    
        (    
            select top 1    
                TripCost    
            from    
                [db-au-stage].dbo.penguin_tblPolicyTransaction_autp tc    
            where    
                tc.PolicyID = p.PolicyID    
        ) tc    
        outer apply    
        (    
            select top 1    
                FinanceProductID,    
                Code as FinanceProductCode,    
                Name as FinanceProductName    
            from    
                [db-au-stage].dbo.penguin_tblFinanceProduct_autp    
            where    
                FinanceProductID = pl.FinanceProductID    
        ) fp            
        outer apply    
        (    
            select top 1    
                case    
                    when ar.Area like '%inbound%' then 'Domestic (Inbound)'    
                    when ar.Domestic = 1 then 'Domestic'    
                    when ar.Domestic = 0 then 'International'    
                    else 'Unknown'    
                end as AreaType,    
                'Area ' + cast(ar.Weighting as varchar) as AreaNumber    
            from    
                [db-au-stage].dbo.penguin_tblPlan_autp pl    
                inner join [db-au-stage].dbo.penguin_tblPlanArea_autp pa on    
                    pl.PlanID = pa.PlanID    
                inner join [db-au-stage].dbo.penguin_tblArea_autp ar on    
                    pa.AreaID = ar.AreaID and    
                    ar.Area = p.Area and    
                    ar.DomainID = p.DomainID    
            where    
                pl.UniquePlanID = pd.UniquePlanID    
        ) ar    
        outer apply    
        (    
            select    
                convert(date, max(CreateDateTime)) ImportDate    
            from    
                [db-au-cmdwh].dbo.penPolicyImport ppi    
            where    
                ppi.Status = 'DONE' and    
                ppi.CountryKey = 'AU' and    
                ppi.PolicyNumber collate database_default  = p.PolicyNumber collate database_default    
        ) ppi    
    
    union all    
    
    select    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        PrefixKey + ltrim(rtrim(p.AlphaCode)) collate database_default OutletAlphaKey,    
        convert(bigint,null) as OutletSKey,    
        PrefixKey + convert(varchar, p.PolicyID) PolicyKey,    
        PrefixKey + convert(varchar, p.PolicyNumber collate database_default) PolicyNoKey,    
        DomainID,    
        p.PolicyID,    
        p.PolicyNumber collate database_default PolicyNumber,    
        p.AlphaCode as AlphaCode,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.IssueDate, TimeZone) IssueDate,    
        convert(date, [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.IssueDate, TimeZone)) IssueDateNoTime,    
        p.IssueDate IssueDateUTC,    
        convert(date, p.IssueDate) IssueDateNoTimeUTC,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.CancelledDate, TimeZone) CancelledDate,    
        p.PolicyStatus as StatusCode,    
        ps.StatusDescription,    
        p.Area,    
        ar.AreaType,    
        p.PrimaryCountry,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.TripStart, TimeZone) TripStart,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.TripEnd, TimeZone) TripEnd,    
        p.AffiliateReference,    
        p.HowDidYouHear,    
        p.AffiliateComments,    
        p.GroupName,    
        p.CompanyName,    
        '' PolicyType,    
        p.isCancellation,    
        pd.ProductID,    
        pp.ProductCode,    
        pp.ProductName,    
        pp.ProductDisplayName,    
        pp.PurchasePath,    
        pd.UniquePlanID,    
        pd.Excess,    
        pd.AreaName,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(pd.PolicyStart, TimeZone) PolicyStart,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(pd.PolicyEnd, TimeZone) PolicyEnd,    
        pd.DaysCovered,    
        pd.MaxDuration,    
        pd.PlanName,    
        pd.PlanType as TripType,    
        pd.PlanID,    
        pl.PlanDisplayName,    
        tc.TripCost as CancellationCover,    
        tc.TripCost,    
        pd.TripDuration,    
        pd.EmailConsent,    
        pd.ShowDiscount IsShowDiscount,    
        p.ExternalReference,  
  p.ExternalReference1,  
        ar.AreaNumber,    
        ppi.ImportDate,    
        p.PreviousPolicyNumber collate database_default PreviousPolicyNumber,    
        p.CurrencyCode,    
        p.CultureCode,    
        p.AreaCode,    
        left(ptax.Value,50) collate database_default as TaxInvoiceNumber,    
        p.PrimaryCountry as MultiDestination,    
        fp.FinanceProductID,    
        case when ar.AreaType = 'International' then 'I' + fp.FinanceProductCode    
             when ar.AreaType = 'Domestic' then 'D' + fp.FinanceProductCode    
             when ar.AreaType = 'Domestic (Inbound)' then 'DI' + fp.FinanceProductCode    
             else 'Unknown'    
        end as FinanceProductCode,    
        fp.FinanceProductName,    
        p.InitialDepositDate,    
  pl.PlanCode    
    from    
        [db-au-stage].dbo.Penguin_tblpolicy_ukcm p    
        cross apply [db-au-stage].dbo.fn_GetDomainKeys(p.DomainId, 'CM', 'UK') dk    
        cross apply    
        (    
            select top 1     
                pd.*    
            from    
                [db-au-stage].dbo.Penguin_tblPolicyDetails_ukcm pd     
            where    
                p.PolicyID = pd.PolicyID    
        ) pd    
        outer apply    
        (    
            select top 1 Value                                    --Tax Invoice Number    
            from    
                [db-au-stage].dbo.penguin_tblPolicyKeyValues_ukcm pkv    
                inner join [db-au-stage].dbo.penguin_tblPolicyKeyValueTypes_ukcm pkt on     
                    pkv.TypeID = pkt.ID    
            where    
                PolicyID = p.PolicyID and    
                pkt.DomainID = p.DomainID and    
                pkt.Code = 'TAXINVOICENO'    
    
        ) ptax    
        outer apply    
        (    
            select top 1    
                StatusDescription    
            from    
                [db-au-stage].dbo.penguin_tblPolicyStatus_ukcm    
            where    
                ID = p.PolicyStatus    
        ) ps    
        outer apply    
        (    
            select top 1    
                ProductCode,    
                ProductName,    
                ProductDisplayName,    
                rv.Value PurchasePath    
            from    
                [db-au-stage].dbo.penguin_tblProduct_ukcm pp    
                inner join [db-au-stage].dbo.penguin_tblReferenceValue_ukcm rv on    
                    rv.ID = pp.PurchasePathID    
            where    
                pp.ProductID = pd.ProductID    
        ) pp    
        outer apply    
        (    
            select top 1    
                DisplayName PlanDisplayName,    
                PlanName,    
                FinanceProductId,    
    PlanCode    
            from    
                [db-au-stage].dbo.penguin_tblPlan_ukcm pl    
            where    
                pl.UniquePlanID = pd.UniquePlanID    
        ) pl    
        outer apply    
        (    
            select top 1    
                TripCost    
            from    
                [db-au-stage].dbo.penguin_tblPolicyTransaction_ukcm tc    
            where    
                tc.PolicyID = p.PolicyID    
        ) tc    
        outer apply    
        (    
            select top 1    
                FinanceProductID,    
                Code as FinanceProductCode,    
                Name as FinanceProductName    
            from    
                [db-au-stage].dbo.penguin_tblFinanceProduct_ukcm    
            where    
                FinanceProductID = pl.FinanceProductID    
        ) fp            
        outer apply    
        (    
            select top 1    
                case    
                    when ar.Area like '%inbound%' then 'Domestic (Inbound)'    
                    when ar.Domestic = 1 then 'Domestic'    
                    when ar.Domestic = 0 then 'International'    
                    else 'Unknown'    
                end as AreaType,    
                'Area ' + cast(ar.Weighting as varchar) as AreaNumber    
            from    
                [db-au-stage].dbo.penguin_tblPlan_ukcm pl    
                inner join [db-au-stage].dbo.penguin_tblPlanArea_ukcm pa on    
                    pl.PlanID = pa.PlanID    
                inner join [db-au-stage].dbo.penguin_tblArea_ukcm ar on    
                    pa.AreaID = ar.AreaID and    
                    ar.Area = p.Area and    
                    ar.DomainID = p.DomainID    
            where    
                pl.UniquePlanID = pd.UniquePlanID    
        ) ar    
        outer apply    
        (    
            select    
                convert(date, max(CreateDateTime)) ImportDate    
            from    
[db-au-cmdwh].dbo.penPolicyImport ppi    
            where    
                ppi.Status = 'DONE' and    
                ppi.CountryKey = 'UK' and    
                ppi.PolicyNumber collate database_default  = p.PolicyNumber collate database_default    
        ) ppi    
  where p.AlphaCode not like 'BK%' ------adding condition to filter out BK.com data  
  
    union all    
    
    select    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        PrefixKey + ltrim(rtrim(p.AlphaCode)) collate database_default OutletAlphaKey,    
        convert(bigint,null) as OutletSKey,    
        PrefixKey + convert(varchar, p.PolicyID) PolicyKey,    
        PrefixKey + convert(varchar, p.PolicyNumber collate database_default) PolicyNoKey,    
        DomainID,    
        p.PolicyID,    
        p.PolicyNumber collate database_default PolicyNumber,    
        p.AlphaCode as AlphaCode,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.IssueDate, TimeZone) IssueDate,    
        convert(date, [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.IssueDate, TimeZone)) IssueDateNoTime,    
        p.IssueDate IssueDateUTC,    
        convert(date, p.IssueDate) IssueDateNoTimeUTC,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.CancelledDate, TimeZone) CancelledDate,    
        p.PolicyStatus as StatusCode,    
        ps.StatusDescription,    
        p.Area,    
        ar.AreaType,    
        p.PrimaryCountry,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.TripStart, TimeZone) TripStart,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(p.TripEnd, TimeZone) TripEnd,    
        p.AffiliateReference,    
        p.HowDidYouHear,    
        p.AffiliateComments,    
        p.GroupName,    
        p.CompanyName,    
        '' PolicyType,    
        p.isCancellation,    
        pd.ProductID,    
        pp.ProductCode,    
        pp.ProductName,    
        pp.ProductDisplayName,    
        pp.PurchasePath,    
        pd.UniquePlanID,    
        pd.Excess,    
        pd.AreaName,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(pd.PolicyStart, TimeZone) PolicyStart,    
        [db-au-stage].dbo.xfn_ConvertUTCtoLocal(pd.PolicyEnd, TimeZone) PolicyEnd,    
        pd.DaysCovered,    
        pd.MaxDuration,    
        pd.PlanName,    
        pd.PlanType as TripType,    
        pd.PlanID,    
        pl.PlanDisplayName,    
        tc.TripCost as CancellationCover,    
        tc.TripCost,    
        pd.TripDuration,    
        pd.EmailConsent,    
        pd.ShowDiscount IsShowDiscount,    
        p.ExternalReference,  
  p.ExternalReference1,  
        ar.AreaNumber,    
        ppi.ImportDate,    
        p.PreviousPolicyNumber collate database_default PreviousPolicyNumber,    
        p.CurrencyCode,    
        p.CultureCode,    
        p.AreaCode,    
        left(ptax.Value,50) collate database_default as TaxInvoiceNumber,    
        p.PrimaryCountry as MultiDestination,    
        fp.FinanceProductID,    
        case when ar.AreaType = 'International' then 'I' + fp.FinanceProductCode    
             when ar.AreaType = 'Domestic' then 'D' + fp.FinanceProductCode    
             when ar.AreaType = 'Domestic (Inbound)' then 'DI' + fp.FinanceProductCode    
             else 'Unknown'    
        end as FinanceProductCode,    
        fp.FinanceProductName,    
        p.InitialDepositDate,    
  pl.PlanCode    
    from    
        [db-au-stage].dbo.Penguin_tblpolicy_uscm p    
        cross apply [db-au-stage].dbo.fn_GetDomainKeys(p.DomainId, 'CM', 'US') dk    
        cross apply    
        (    
            select top 1     
                pd.*    
            from    
                [db-au-stage].dbo.Penguin_tblPolicyDetails_uscm pd     
            where    
                p.PolicyID = pd.PolicyID    
        ) pd    
        outer apply    
        (    
            select top 1 Value                                    --Tax Invoice Number    
            from    
                [db-au-stage].dbo.penguin_tblPolicyKeyValues_uscm pkv    
                inner join [db-au-stage].dbo.penguin_tblPolicyKeyValueTypes_uscm pkt on     
                    pkv.TypeID = pkt.ID    
            where    
                PolicyID = p.PolicyID and    
                pkt.DomainID = p.DomainID and    
                pkt.Code = 'TAXINVOICENO'    
    
        ) ptax    
        outer apply    
        (    
            select top 1    
                StatusDescription    
            from    
                [db-au-stage].dbo.penguin_tblPolicyStatus_uscm    
            where    
                ID = p.PolicyStatus    
        ) ps    
        outer apply    
        (    
            select top 1    
                ProductCode,    
                ProductName,    
                ProductDisplayName,    
                rv.Value PurchasePath    
            from    
                [db-au-stage].dbo.penguin_tblProduct_uscm pp    
                inner join [db-au-stage].dbo.penguin_tblReferenceValue_uscm rv on    
                    rv.ID = pp.PurchasePathID    
            where    
                pp.ProductID = pd.ProductID    
        ) pp    
        outer apply    
        (    
            select top 1    
                DisplayName PlanDisplayName,    
                PlanName,    
                FinanceProductID,    
    PlanCode    
            from    
                [db-au-stage].dbo.penguin_tblPlan_uscm pl    
            where    
                pl.UniquePlanID = pd.UniquePlanID    
        ) pl    
        outer apply    
        (    
            select top 1    
                TripCost    
            from    
                [db-au-stage].dbo.penguin_tblPolicyTransaction_uscm tc    
            where    
                tc.PolicyID = p.PolicyID    
        ) tc    
        outer apply    
        (    
            select top 1    
                FinanceProductID,    
                Code as FinanceProductCode,    
                Name as FinanceProductName    
            from    
                [db-au-stage].dbo.penguin_tblFinanceProduct_uscm    
            where    
                FinanceProductID = pl.FinanceProductID    
        ) fp            
        outer apply    
        (    
            select top 1    
                case    
                    when ar.Area like '%inbound%' then 'Domestic (Inbound)'    
                    when ar.Domestic = 1 then 'Domestic'    
   when ar.Domestic = 0 then 'International'    
                    else 'Unknown'    
                end as AreaType,    
                'Area ' + cast(ar.Weighting as varchar) as AreaNumber    
            from    
                [db-au-stage].dbo.penguin_tblPlan_uscm pl    
                inner join [db-au-stage].dbo.penguin_tblPlanArea_uscm pa on    
                    pl.PlanID = pa.PlanID    
                inner join [db-au-stage].dbo.penguin_tblArea_uscm ar on    
                    pa.AreaID = ar.AreaID and    
                    ar.Area = p.Area and    
                    ar.DomainID = p.DomainID    
            where    
                pl.UniquePlanID = pd.UniquePlanID    
        ) ar    
        outer apply    
        (    
            select    
                convert(date, max(CreateDateTime)) ImportDate    
            from    
                [db-au-cmdwh].dbo.penPolicyImport ppi    
            where    
                ppi.Status = 'DONE' and    
                ppi.CountryKey = 'US' and    
                ppi.PolicyNumber collate database_default  = p.PolicyNumber collate database_default    
        ) ppi    
    
    
    /*************************************************************/    
    --Update Policies where AreaType is STILL null    
    /*************************************************************/    
    
    update etl_penPolicy_test    
    set AreaType =    
        case    
            when CountryKey = 'AU' and AreaName like '%Inbound%' then 'Domestic (Inbound)'    
            when CountryKey = 'AU' and AreaName = 'Australia' then 'Domestic'    
            when CountryKey = 'NZ' and AreaName like '%Inbound%' then 'Domestic (Inbound)'    
            when CountryKey = 'NZ' and AreaName in ('New Zealand Only','New Zealand') then 'Domestic'    
            when CountryKey = 'SG' and AreaName = 'Singapore' then 'Domestic'    
            when CountryKey = 'MY' and AreaName = 'Domestic' then 'Domestic'    
            when CountryKey = 'UK' and AreaName = 'Domestic Dummy' then 'Domestic'    
            else 'International'    
        end    
    where    
        AreaType is null    
    
        
    --update PrimaryCountry to destination with highest risk    
    update a    
    set PrimaryCountry = case when b.Destination is not null then b.Destination        --get primary destination with highest risk    
                              when b.Destination is null then c.Destination            --there is no highest risk destination for some unknown reason, then get first destination    
                              else null                                                --policy has no destination    
                        end    
    from    
        etl_penPolicy_test a    
        outer apply                                    
        (    
            select top 1 Destination    
            from [db-au-workspace].dbo.penPolicyDestination_test    
            where     
                isPrimaryDestination = 1 and    
                PolicyKey = a.PolicyKey    
        ) b    
        outer apply                                    
        (    
            select top 1 Destination    
            from [db-au-workspace].dbo.penPolicyDestination_test    
            where     
                PolicyKey = a.PolicyKey and    
                isPrimaryDestination = 0    
        ) c    
    
    
    /*************************************************************/    
    --Update UserSKey in etl_penPolicy_testTransaction records    
    --For UserStatus = Current    
    /*************************************************************/    
    update p    
    set p.OutletSKey = o.OutletSKey    
    from    
        etl_penPolicy_test p    
        inner join [db-au-cmdwh].dbo.penOutlet o on    
            p.OutletAlphaKey = o.OutletAlphaKey and    
            o.OutletStatus = 'Current'    
    
    /*************************************************************/    
    --Update UserSKey in etl_penPolicy_test records    
    --For UserStatus = Not Current AND    
    --PolicyTransaction IssueDate between UserStartDate and UserEndDate    
    /*************************************************************/    
    update p    
    set p.OutletSKey = o.OutletSKey    
    from    
        etl_penPolicy_test p    
        inner join [db-au-cmdwh].dbo.penOutlet o on    
            o.OutletAlphaKey = p.OutletAlphaKey and    
            o.OutletStatus = 'Not Current' and    
            p.IssueDate >= convert(date, o.OutletStartDate) and    
            p.IssueDate <  convert(date, dateadd(day, 1, o.OutletEndDate))    
    
    
    /*************************************************************/    
    --delete existing policies or create table if table doesnt exist    
    /*************************************************************/    
    if object_id('[db-au-workspace].dbo.penPolicy_test') is null    
    begin    
    
        create table [db-au-workspace].dbo.[penPolicy_test]    
        (    
            [CountryKey] varchar(2) not null,    
            [CompanyKey] varchar(5) not null,    
            [OutletAlphaKey] nvarchar(50) null,    
            [OutletSKey] bigint null,    
            [PolicyKey] varchar(41) null,    
            [PolicyNoKey] varchar(100) null,    
            [PolicyID] int not null,    
            [PolicyNumber] varchar(50) not null,    
            [AlphaCode] nvarchar(60) null,    
            [IssueDate] datetime not null,    
            [IssueDateNoTime] datetime not null,    
            [CancelledDate] datetime null,    
            [StatusCode] int null,    
            [StatusDescription] nvarchar(50) null,    
            [Area] nvarchar(100) null,    
            [PrimaryCountry] nvarchar(MAX),    
            [TripStart] datetime null,    
            [TripEnd] datetime null,    
            [AffiliateReference] nvarchar(200) null,    
            [HowDidYouHear] nvarchar(200) null,    
            [AffiliateComments] varchar(500) null,    
            [GroupName] nvarchar(100) null,    
            [CompanyName] nvarchar(100) null,    
            [PolicyType] nvarchar(50) null,    
            [isCancellation] bit not null,    
            [ProductID] int not null,    
            [ProductCode] nvarchar(50) null,    
            [ProductName] nvarchar(50) null,    
            [ProductDisplayName] nvarchar(50) null,    
            [UniquePlanID] int not null,    
            [Excess] money not null,    
            [AreaName] nvarchar(100) null,    
            [PolicyStart] datetime not null,    
            [PolicyEnd] datetime not null,    
            [DaysCovered] int null,    
            [MaxDuration] int null,    
            [PlanName] nvarchar(50) null,    
            [TripType] nvarchar(50) null,    
            [PlanID] int null,    
            [PlanDisplayName] nvarchar(100) null,    
            [CancellationCover] nvarchar(50) null,    
            [TripCost] nvarchar(50) null,    
            [TripDuration] int null,    
            [EmailConsent] bit null,    
            [AreaType] varchar(25) null,    
            [PurchasePath] nvarchar(50) null,    
            [IsShowDiscount] bit null,    
            [ExternalReference] nvarchar(100) null,  
   [ExternalReference1] nvarchar(225) null,  
            [DomainKey] varchar(41) null,    
            [DomainID] int null,    
            [IssueDateUTC] datetime null,    
            [IssueDateNoTimeUTC] datetime null,    
            [AreaNumber] varchar(20) null,    
            [isTripsPolicy] int null,    
            [ImportDate] datetime null,    
            [PreviousPolicyNumber] varchar(50) null,    
            [CurrencyCode] varchar(3) null,    
            [CultureCode] nvarchar(20) null,    
            [AreaCode] nvarchar(3) null,    
            [TaxInvoiceNumber] nvarchar(50) null,    
            [MultiDestination] nvarchar(max) null,    
            [FinanceProductID] int null,    
            [FinanceProductCode] nvarchar(10) null,    
            [FinanceProductName] nvarchar(125) null,    
            [InitialDepositDate] date null,    
   [PlanCode] nvarchar(50) null    
        )    
    
        create clustered index idx_penPolicy_test_PolicyKey on [db-au-workspace].dbo.penPolicy_test(PolicyKey)    
        create nonclustered index idx_penPolicy_test_AlphaCode on [db-au-workspace].dbo.penPolicy_test(AlphaCode)    
        create nonclustered index idx_penPolicy_test_ExternalReference on [db-au-workspace].dbo.penPolicy_test(ExternalReference)    
        create nonclustered index idx_penPolicy_test_ImportDate on [db-au-workspace].dbo.penPolicy_test(ImportDate)    
        create nonclustered index idx_penPolicy_test_IssueDate on [db-au-workspace].dbo.penPolicy_test(IssueDate,StatusDescription) include (OutletAlphaKey,PolicyKey)    
        create nonclustered index idx_penPolicy_test_OutletAlphaKey on [db-au-workspace].dbo.penPolicy_test(OutletAlphaKey) include (PolicyKey,PolicyNumber,AffiliateReference,ProductCode,ProductName)    
        create nonclustered index idx_penPolicy_test_OutletSKey on [db-au-workspace].dbo.penPolicy_test(OutletSKey)    
        create nonclustered index idx_penPolicy_test_PolicyID on [db-au-workspace].dbo.penPolicy_test(PolicyID)    
        create nonclustered index idx_penPolicy_test_PolicyNoKey on [db-au-workspace].dbo.penPolicy_test(PolicyNoKey)    
        create nonclustered index idx_penPolicy_test_PolicyNumber on [db-au-workspace].dbo.penPolicy_test(PolicyNumber,AlphaCode,CountryKey)    
        create nonclustered index idx_penPolicy_test_TravelDates on [db-au-workspace].dbo.penPolicy_test(TripStart,TripEnd)    
    
    end    
    
    
    /*************************************************************/    
    -- Transfer data from  etl_penPolicy_test to [db-au-cmdwh].dbo.penPolicy    
    /*************************************************************/    
    begin transaction penPolicy_test    
    
    begin try    
    
        delete a    
        from    
            [db-au-workspace].dbo.penPolicy_test a    
            inner join etl_penPolicy_test b on    
                a.PolicyKey = b.PolicyKey and    
                a.OutletAlphaKey = b.OutletAlphaKey    
    
        insert into [db-au-workspace].dbo.penPolicy_test with (tablockx)    
        (    
            CountryKey,    
            CompanyKey,    
            OutletAlphaKey,    
            OutletSKey,    
            PolicyKey,    
            PolicyNoKey,    
            PolicyID,    
            PolicyNumber,    
            AlphaCode,    
            IssueDate,    
            IssueDateNoTime,    
            CancelledDate,    
            StatusCode,    
            StatusDescription,    
            Area,    
            PrimaryCountry,    
            TripStart,    
            TripEnd,    
            AffiliateReference,    
            HowDidYouHear,    
            AffiliateComments,    
            GroupName,    
            CompanyName,    
            PolicyType,    
            isCancellation,    
            ProductID,    
            ProductCode,    
            ProductName,    
            ProductDisplayName,    
            UniquePlanID,    
            Excess,    
            AreaName,    
            PolicyStart,    
            PolicyEnd,    
            DaysCovered,    
            MaxDuration,    
            PlanName,    
            TripType,    
            PlanID,    
            PlanDisplayName,    
            CancellationCover,    
            TripCost,    
            TripDuration,    
            EmailConsent,    
            AreaType,    
            PurchasePath,    
            IsShowDiscount,    
            ExternalReference,  
   ExternalReference1,  
            DomainKey,    
            DomainID,    
            IssueDateUTC,    
            IssueDateNoTimeUTC,    
            AreaNumber,    
            isTripsPolicy,    
            ImportDate,    
            PreviousPolicyNumber,    
            CurrencyCode,    
            CultureCode,    
            AreaCode,    
            TaxInvoiceNumber,    
            MultiDestination,    
            FinanceProductID,    
            FinanceProductCode,    
            FinanceProductName,    
            InitialDepositDate,    
   PlanCode    
        )    
        select    
            CountryKey,    
            CompanyKey,    
            OutletAlphaKey,    
            OutletSKey,    
            PolicyKey,    
            PolicyNoKey,    
            PolicyID,    
            PolicyNumber,    
            AlphaCode,    
            IssueDate,    
            IssueDateNoTime,    
            CancelledDate,    
            StatusCode,    
            StatusDescription,    
            Area,    
            PrimaryCountry,    
            TripStart,    
            TripEnd,    
            AffiliateReference,    
            HowDidYouHear,    
            AffiliateComments,    
            GroupName,    
            CompanyName,    
            PolicyType,    
            isCancellation,    
            ProductID,    
            ProductCode,    
            ProductName,    
            ProductDisplayName,    
            UniquePlanID,    
            Excess,    
            AreaName,    
            PolicyStart,    
            PolicyEnd,    
            DaysCovered,    
            MaxDuration,    
            PlanName,    
            TripType,    
            PlanID,    
            PlanDisplayName,    
            CancellationCover,    
            TripCost,    
            TripDuration,    
            EmailConsent,    
            AreaType,    
            PurchasePath,    
            IsShowDiscount,    
            ExternalReference,  
   ExternalReference1,  
            DomainKey,    
            DomainID,    
            IssueDateUTC,    
            IssueDateNoTimeUTC,    
            AreaNumber,    
            0,                            --all policies should be coming from Penguin Policy    
            ImportDate,    
            PreviousPolicyNumber,    
            CurrencyCode,    
            CultureCode,    
            AreaCode,    
            TaxInvoiceNumber,    
            MultiDestination,    
            FinanceProductID,    
            FinanceProductCode,    
            FinanceProductName,    
            InitialDepositDate,    
   PlanCode    
        from    
            etl_penPolicy_test    
    
    end try    
    
    begin catch    
    
        if @@trancount > 0    
            rollback transaction penPolicy_test    
    
        --exec syssp_genericerrorhandler 'penPolicy data refresh failed'    
    
    end catch    
    
    if @@trancount > 0    
        commit transaction penPolicy_test    
    
    /* policy related ETLs go here */    
    
    --exec etlsp_cmdwh_penPolicyCompetitor    
    
end    
    
    
    
GO
