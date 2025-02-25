USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPolicyAddOnTax]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_penPolicyAddOnTax]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20120124
Prerequisite:   Requires penguin data model successfully run prior to execution
Description:    penPolicyAddOnTax transformation adds essential key fields

Change History:
                20120203 - LT - Procedure created
                20121107 - LS - refactoring & domain related changes
                20130617 - LS - TFS 7664/8556/8557, UK Penguin
                20131204 - LS - case 19524, index optimisation for new pricing calculation
                20140616 - LS - TFS 12416, Penguin 9.0 / China (Unicode)
                20140617 - LS - TFS 12416, schema and index cleanup
                20140618 - LS - TFS 12416, do not truncate surrogate key, let it fail and known instead of producing invalid data
                20140715 - LS - F 21325, use transaction, other session will not see data gets deleted until after it's replaced (intraday refresh)
				20160321 - LT - Penguin 18.0, added US Penguin instance

*************************************************************************************************************************************/

    set nocount on

    /* staging index */
    exec etlsp_StagingIndex_Penguin

    if object_id('etl_penPolicyAddOnTax') is not null
        drop table etl_penPolicyAddOnTax

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, pat.ID) PolicyAddOnTaxKey,
        PrefixKey + convert(varchar, pat.PolicyAddOnID) PolicyAddOnKey,
        PrefixKey + convert(varchar, pat.TaxID) TaxKey,
        DomainID,
        pat.ID as PolicyAddOnTaxID,
        pat.PolicyAddOnID,
        pat.TaxID,
        tx.TaxName,
        tx.TaxRate,
        tx.TaxType,
        sum(
            case
                when pat.isPOSDiscount = 0 then pat.TaxAmount
                else 0
            end
        ) as TaxAmount,
        sum(
            case
                when pat.isPOSDiscount = 0 then pat.TaxOnAgentComm
                else 0
            end
        ) as TaxOnAgentComm,
        sum(
            case
                when pat.isPOSDiscount = 1 then pat.TaxAmount
                else 0
            end
        ) as TaxAmountPOSDisc,
        sum(
            case
                when pat.isPOSDiscount = 1 then pat.TaxOnAgentComm
                else 0
            end
        ) as TaxOnAgentCommPOSDisc
    into etl_penPolicyAddOnTax
    from
        penguin_tblPolicyAddOnTax_aucm pat
        inner join penguin_tblPolicyAddon_aucm pa on
            pa.ID = pat.PolicyAddOnID
        inner join penguin_tblPolicyTransaction_aucm pt
            on pt.ID = pa.PolicyTransactionId
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'AU') dk
        outer apply
        (
            select top 1
                ta.TaxName,
                ta.TaxRate,
                tt.TaxType
            from
                penguin_tblTax_aucm ta
                inner join penguin_tblTaxType_aucm tt on
                    ta.TaxTypeID = tt.TaxTypeID
            where
                ta.TaxID = pat.TaxID
        ) tx
    group by
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, pat.ID),
        PrefixKey + convert(varchar, pat.PolicyAddOnID),
        PrefixKey + convert(varchar, pat.TaxID),
        DomainID,
        pat.ID,
        pat.PolicyAddOnID,
        pat.TaxID,
        tx.TaxName,
        tx.TaxRate,
        tx.TaxType

    union all

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, pat.ID) PolicyAddOnTaxKey,
        PrefixKey + convert(varchar, pat.PolicyAddOnID) PolicyAddOnKey,
        PrefixKey + convert(varchar, pat.TaxID) TaxKey,
        DomainID,
        pat.ID as PolicyAddOnTaxID,
        pat.PolicyAddOnID,
        pat.TaxID,
        tx.TaxName,
        tx.TaxRate,
        tx.TaxType,
        sum(
            case
                when pat.isPOSDiscount = 0 then pat.TaxAmount
                else 0
            end
        ) as TaxAmount,
        sum(
            case
                when pat.isPOSDiscount = 0 then pat.TaxOnAgentComm
                else 0
            end
        ) as TaxOnAgentComm,
        sum(
            case
                when pat.isPOSDiscount = 1 then pat.TaxAmount
                else 0
            end
        ) as TaxAmountPOSDisc,
        sum(
            case
                when pat.isPOSDiscount = 1 then pat.TaxOnAgentComm
                else 0
            end
        ) as TaxOnAgentCommPOSDisc
    from
        penguin_tblPolicyAddOnTax_autp pat
        inner join penguin_tblPolicyAddon_autp pa on
            pa.ID = pat.PolicyAddOnID
        inner join penguin_tblPolicyTransaction_autp pt
            on pt.ID = pa.PolicyTransactionId
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'TIP', 'AU') dk
        outer apply
        (
            select top 1
                ta.TaxName,
                ta.TaxRate,
                tt.TaxType
            from
                penguin_tblTax_autp ta
                inner join penguin_tblTaxType_autp tt on
                    ta.TaxTypeID = tt.TaxTypeID
            where
                ta.TaxID = pat.TaxID
        ) tx
    group by
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, pat.ID),
        PrefixKey + convert(varchar, pat.PolicyAddOnID),
        PrefixKey + convert(varchar, pat.TaxID),
        DomainID,
        pat.ID,
        pat.PolicyAddOnID,
        pat.TaxID,
        tx.TaxName,
        tx.TaxRate,
        tx.TaxType

    union all

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, pat.ID) PolicyAddOnTaxKey,
        PrefixKey + convert(varchar, pat.PolicyAddOnID) PolicyAddOnKey,
        PrefixKey + convert(varchar, pat.TaxID) TaxKey,
        DomainID,
        pat.ID as PolicyAddOnTaxID,
        pat.PolicyAddOnID,
        pat.TaxID,
        tx.TaxName,
        tx.TaxRate,
        tx.TaxType,
        sum(
            case
                when pat.isPOSDiscount = 0 then pat.TaxAmount
                else 0
            end
        ) as TaxAmount,
        sum(
            case
                when pat.isPOSDiscount = 0 then pat.TaxOnAgentComm
                else 0
            end
        ) as TaxOnAgentComm,
        sum(
            case
                when pat.isPOSDiscount = 1 then pat.TaxAmount
                else 0
            end
        ) as TaxAmountPOSDisc,
        sum(
            case
                when pat.isPOSDiscount = 1 then pat.TaxOnAgentComm
                else 0
            end
        ) as TaxOnAgentCommPOSDisc
    from
        penguin_tblPolicyAddOnTax_ukcm pat
        inner join penguin_tblPolicyAddon_ukcm pa on
            pa.ID = pat.PolicyAddOnID
        inner join penguin_tblPolicyTransaction_ukcm pt
            on pt.ID = pa.PolicyTransactionId
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'UK') dk
        outer apply
        (
            select top 1
                ta.TaxName,
                ta.TaxRate,
                tt.TaxType
            from
                penguin_tblTax_ukcm ta
                inner join penguin_tblTaxType_ukcm tt on
                    ta.TaxTypeID = tt.TaxTypeID
            where
                ta.TaxID = pat.TaxID
        ) tx
    group by
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, pat.ID),
        PrefixKey + convert(varchar, pat.PolicyAddOnID),
        PrefixKey + convert(varchar, pat.TaxID),
        DomainID,
        pat.ID,
        pat.PolicyAddOnID,
        pat.TaxID,
        tx.TaxName,
        tx.TaxRate,
        tx.TaxType

    union all

    select
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, pat.ID) PolicyAddOnTaxKey,
        PrefixKey + convert(varchar, pat.PolicyAddOnID) PolicyAddOnKey,
        PrefixKey + convert(varchar, pat.TaxID) TaxKey,
        DomainID,
        pat.ID as PolicyAddOnTaxID,
        pat.PolicyAddOnID,
        pat.TaxID,
        tx.TaxName,
        tx.TaxRate,
        tx.TaxType,
        sum(
            case
                when pat.isPOSDiscount = 0 then pat.TaxAmount
                else 0
            end
        ) as TaxAmount,
        sum(
            case
                when pat.isPOSDiscount = 0 then pat.TaxOnAgentComm
                else 0
            end
        ) as TaxOnAgentComm,
        sum(
            case
                when pat.isPOSDiscount = 1 then pat.TaxAmount
                else 0
            end
        ) as TaxAmountPOSDisc,
        sum(
            case
                when pat.isPOSDiscount = 1 then pat.TaxOnAgentComm
                else 0
            end
        ) as TaxOnAgentCommPOSDisc
    from
        penguin_tblPolicyAddOnTax_uscm pat
        inner join penguin_tblPolicyAddon_uscm pa on
            pa.ID = pat.PolicyAddOnID
        inner join penguin_tblPolicyTransaction_uscm pt
            on pt.ID = pa.PolicyTransactionId
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'US') dk
        outer apply
        (
            select top 1
                ta.TaxName,
                ta.TaxRate,
                tt.TaxType
            from
                penguin_tblTax_uscm ta
                inner join penguin_tblTaxType_uscm tt on
                    ta.TaxTypeID = tt.TaxTypeID
            where
                ta.TaxID = pat.TaxID
        ) tx
    group by
        CountryKey,
        CompanyKey,
        PrefixKey + convert(varchar, pat.ID),
        PrefixKey + convert(varchar, pat.PolicyAddOnID),
        PrefixKey + convert(varchar, pat.TaxID),
        DomainID,
        pat.ID,
        pat.PolicyAddOnID,
        pat.TaxID,
        tx.TaxName,
        tx.TaxRate,
        tx.TaxType


    if object_id('[db-au-cmdwh].dbo.penPolicyAddOnTax') is null
    begin

        create table [db-au-cmdwh].dbo.[penPolicyAddOnTax]
        (
            [CountryKey] varchar(2) not null,
            [CompanyKey] varchar(5) not null,
            [PolicyAddOnTaxKey] varchar(41) null,
            [PolicyAddOnKey] varchar(41) null,
            [TaxKey] varchar(41) null,
            [PolicyAddOnTaxID] int not null,
            [PolicyAddOnID] int not null,
            [TaxID] int not null,
            [TaxName] nvarchar(50) null,
            [TaxRate] numeric(18,5) null,
            [TaxType] nvarchar(50) null,
            [TaxAmount] money null,
            [TaxOnAgentComm] money null,
            [TaxAmountPOSDisc] money null,
            [TaxOnAgentCommPOSDisc] money null,
            [DomainID] int null
        )

        create clustered index idx_penPolicyAddOnTax_PolicyAddOnTaxID on [db-au-cmdwh].dbo.penPolicyAddOnTax(PolicyAddOnTaxID)
        create nonclustered index idx_penPolicyAddOnTax_PolicyAddonKey on [db-au-cmdwh].dbo.penPolicyAddOnTax(PolicyAddOnKey) include (TaxName,TaxType,TaxAmount,TaxOnAgentComm,TaxAmountPOSDisc,TaxOnAgentCommPOSDisc)
        create nonclustered index idx_penPolicyAddOnTax_PolicyAddOnTaxKey on [db-au-cmdwh].dbo.penPolicyAddOnTax(PolicyAddOnTaxKey)

    end
    
    
    begin transaction penPolicyAddOnTax
    
    begin try

        delete a
        from
            [db-au-cmdwh].dbo.penPolicyAddOnTax a
            inner join etl_penPolicyAddOnTax b on
                a.PolicyAddOnTaxKey = b.PolicyAddOnTaxKey

        insert [db-au-cmdwh].dbo.penPolicyAddOnTax with(tablockx)
        (
            CountryKey,
            CompanyKey,
            PolicyAddOnTaxKey,
            PolicyAddOnKey,
            TaxKey,
            DomainID,
            PolicyAddOnTaxID,
            PolicyAddOnID,
            TaxID,
            TaxName,
            TaxRate,
            TaxType,
            TaxAmount,
            TaxOnAgentComm,
            TaxAmountPOSDisc,
            TaxOnAgentCommPOSDisc
        )
        select
            CountryKey,
            CompanyKey,
            PolicyAddOnTaxKey,
            PolicyAddOnKey,
            TaxKey,
            DomainID,
            PolicyAddOnTaxID,
            PolicyAddOnID,
            TaxID,
            TaxName,
            TaxRate,
            TaxType,
            TaxAmount,
            TaxOnAgentComm,
            TaxAmountPOSDisc,
            TaxOnAgentCommPOSDisc
        from
            etl_penPolicyAddOnTax

    end try
    
    begin catch
    
        if @@trancount > 0
            rollback transaction penPolicyAddOnTax
            
        exec syssp_genericerrorhandler 'penPolicyAddOnTax data refresh failed'
        
    end catch    

    if @@trancount > 0
        commit transaction penPolicyAddOnTax

end

GO
