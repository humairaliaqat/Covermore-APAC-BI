USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPolicyTransactionAllocation]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_penPolicyTransactionAllocation]    
as    
begin    
/************************************************************************************************************************************    
Author:         Linus Tor    
Date:           20130527    
Prerequisite:   Requires Penguin Data Model ETL successfully run.    
Description:    PolicyAllocation table contains payment allocation attributes.    
                This transformation adds essential key fields and denormalises tables.    
Change History:    
                20130607 - LT - Procedure created    
                20130617 - LS - TFS 7664/8556/8557, UK Penguin    
                20130808 - LS - bug fix, keys definitions are wrong (copy/paste error)    
                20130815 - LS - bug fix, fn_GetOutletDomainKeys should have been fn_GetDomainKeys    
                20140715 - LS - F 21325, use transaction, other session will not see data gets deleted until after it's replaced (intraday refresh)    
    20140805 - LT - TFS 13021, changed PolicyNumber from bigint to varchar(50)    
    20160321 - LT - Penguin 18.0, added US penguin instance    
    20210306, SS, CHG0034615 Add filter for BK.com  
*************************************************************************************************************************************/    
    
    set nocount on    
    
    /* staging index */    
    exec etlsp_StagingIndex_Penguin    
    
    if object_id('etl_penPolicyTransactionAllocation') is not null    
        drop table etl_penPolicyTransactionAllocation    
    
    select    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        left(PrefixKey + convert(varchar, p.PolicyAllocationID), 41) as PolicyAllocationKey,    
        left(PrefixKey + convert(varchar, p.PaymentAllocationID), 41) as PaymentAllocationKey,    
        left(PrefixKey + convert(varchar, p.PolicyTransactionID), 41) as PolicyTransactionKey,    
        p.PolicyAllocationID,    
        p.PaymentAllocationID,    
        p.PolicyTransactionID,    
        p.TripsPolicyNumber  collate database_default PolicyNumber,    
        p.Amount,    
        p.AllocationAmount,    
        p.AmountType,    
        p.Comments,    
        p.[Status]    
    into etl_penPolicyTransactionAllocation    
    from    
        dbo.penguin_tblPolicyTransactionAllocation_aucm p    
        inner join dbo.penguin_tblPaymentAllocation_aucm pa on    
            p.PaymentAllocationID = pa.PaymentAllocationID    
        inner join dbo.penguin_tblOutlet_aucm o on    
            pa.OutletID = o.OutletID    
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'CM', 'AU') dk    
    
    union all    
    
    select    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        left(PrefixKey + convert(varchar, p.PolicyAllocationID), 41) as PolicyAllocationKey,    
        left(PrefixKey + convert(varchar, p.PaymentAllocationID), 41) as PaymentAllocationKey,    
        left(PrefixKey + convert(varchar, p.PolicyTransactionID), 41) as PolicyTransactionKey,    
        p.PolicyAllocationID,    
        p.PaymentAllocationID,    
        p.PolicyTransactionID,    
        p.TripsPolicyNumber  collate database_default PolicyNumber,    
        p.Amount,    
        p.AllocationAmount,    
        p.AmountType,    
        p.Comments,    
        p.[Status]    
    from    
        dbo.penguin_tblPolicyTransactionAllocation_autp p    
        inner join dbo.penguin_tblPaymentAllocation_autp pa on    
            p.PaymentAllocationID = pa.PaymentAllocationID    
        inner join dbo.penguin_tblOutlet_autp o on    
            pa.OutletID = o.OutletID    
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'TIP', 'AU') dk    
    
    union all    
    
    select    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        left(PrefixKey + convert(varchar, p.PolicyAllocationID), 41) as PolicyAllocationKey,    
        left(PrefixKey + convert(varchar, p.PaymentAllocationID), 41) as PaymentAllocationKey,    
        left(PrefixKey + convert(varchar, p.PolicyTransactionID), 41) as PolicyTransactionKey,    
        p.PolicyAllocationID,    
        p.PaymentAllocationID,    
        p.PolicyTransactionID,    
        p.TripsPolicyNumber  collate database_default PolicyNumber,    
        p.Amount,    
        p.AllocationAmount,    
        p.AmountType,    
        p.Comments,    
        p.[Status]    
    from    
        dbo.penguin_tblPolicyTransactionAllocation_ukcm p    
        inner join dbo.penguin_tblPaymentAllocation_ukcm pa on    
            p.PaymentAllocationID = pa.PaymentAllocationID    
        inner join dbo.penguin_tblOutlet_ukcm o on    
            pa.OutletID = o.OutletID    
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'CM', 'UK') dk    
 where left(PrefixKey + convert(varchar, p.PaymentAllocationID), 41) not in  
 (select left(PrefixKey + convert(varchar, p.PaymentAllocationID), 41)   
 from dbo.penguin_tblPaymentAllocation_ukcm p inner join dbo.penguin_tblOutlet_ukcm o on      
            p.OutletID = o.OutletID    
 cross apply dbo.fn_GetDomainKeys(o.DomainID, 'CM', 'UK') dk   
 where p.OutletID in (select OutletId from penguin_tblOutlet_ukcm where AlphaCode like 'BK%')) ------adding condition to filter out BK.com data  
   
    union all    
    
    select    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        left(PrefixKey + convert(varchar, p.PolicyAllocationID), 41) as PolicyAllocationKey,    
        left(PrefixKey + convert(varchar, p.PaymentAllocationID), 41) as PaymentAllocationKey,    
        left(PrefixKey + convert(varchar, p.PolicyTransactionID), 41) as PolicyTransactionKey,    
        p.PolicyAllocationID,    
        p.PaymentAllocationID,    
        p.PolicyTransactionID,    
        p.TripsPolicyNumber  collate database_default PolicyNumber,    
        p.Amount,    
        p.AllocationAmount,    
        p.AmountType,    
        p.Comments,    
        p.[Status]    
    from    
        dbo.penguin_tblPolicyTransactionAllocation_uscm p    
        inner join dbo.penguin_tblPaymentAllocation_uscm pa on    
            p.PaymentAllocationID = pa.PaymentAllocationID    
        inner join dbo.penguin_tblOutlet_uscm o on    
            pa.OutletID = o.OutletID    
        cross apply dbo.fn_GetDomainKeys(o.DomainID, 'CM', 'US') dk    
    
    
    if object_id('[db-au-cmdwh].dbo.penPolicyTransactionAllocation') is null    
    begin    
    
        create table [db-au-cmdwh].[dbo].penPolicyTransactionAllocation    
        (    
            [CountryKey] [varchar](2) null,    
            [CompanyKey] [varchar](5) null,    
            [DomainKey] [varchar](41) null,    
            [PolicyAllocationKey] [varchar](41) null,    
            [PaymentAllocationKey] [varchar](41) null,    
            [PolicyTransactionKey] [varchar](41) null,    
            [PolicyAllocationID] [int] null,    
            [PaymentAllocationID] [int] null,    
            [PolicyTransactionID] [int] null,    
            [PolicyNumber] [varchar](50) null,    
            [Amount] [money] null,    
            [AllocationAmount] [money] null,    
            [AmountType] [varchar](15) null,    
            [Comments] [varchar](255) null,    
            [Status] [varchar](15) null    
        )    
    
        create clustered index idx_penPolicyTransactionAllocation_PolicyAllocationKey on [db-au-cmdwh].dbo.penPolicyTransactionAllocation(PolicyAllocationKey)    
        create index idx_penPolicyTransactionAllocation_CountryKey on [db-au-cmdwh].dbo.penPolicyTransactionAllocation(CountryKey)    
        create index idx_penPolicyTransactionAllocation_PaymentAllocationKey on [db-au-cmdwh].dbo.penPolicyTransactionAllocation(PaymentAllocationKey)    
        create index idx_penPolicyTransactionAllocation_PolicyTransactionKey on [db-au-cmdwh].dbo.penPolicyTransactionAllocation(PolicyTransactionKey)    
    end    
        
        
    begin transaction penPolicyTransactionAllocation    
        
    begin try    
        
        delete a    
        from    
            [db-au-cmdwh].dbo.penPolicyTransactionAllocation a    
            inner join etl_penPolicyTransactionAllocation b on    
                a.PolicyAllocationKey = b.PolicyAllocationKey    
    
        insert [db-au-cmdwh].dbo.penPolicyTransactionAllocation with(tablockx)    
        (    
            [CountryKey],    
            [CompanyKey],    
            [DomainKey],    
            [PolicyAllocationKey],    
            [PaymentAllocationKey],    
            [PolicyTransactionKey],    
            [PolicyAllocationID],    
            [PaymentAllocationID],    
            [PolicyTransactionID],    
            [PolicyNumber],    
            [Amount],    
            [AllocationAmount],    
            [AmountType],    
            [Comments],    
            [Status]    
        )    
        select    
            [CountryKey],    
            [CompanyKey],    
            [DomainKey],    
   [PolicyAllocationKey],    
            [PaymentAllocationKey],    
            [PolicyTransactionKey],    
            [PolicyAllocationID],    
            [PaymentAllocationID],    
            [PolicyTransactionID],    
            [PolicyNumber],    
            [Amount],    
            [AllocationAmount],    
            [AmountType],    
            [Comments],    
            [Status]    
        from    
            etl_penPolicyTransactionAllocation    
    
    end try    
        
    begin catch    
        
        if @@trancount > 0    
            rollback transaction penPolicyTransactionAllocation    
                
        exec syssp_genericerrorhandler 'penPolicyTransactionAllocation data refresh failed'    
            
    end catch        
    
    if @@trancount > 0    
        commit transaction penPolicyTransactionAllocation    
    
end    
GO
