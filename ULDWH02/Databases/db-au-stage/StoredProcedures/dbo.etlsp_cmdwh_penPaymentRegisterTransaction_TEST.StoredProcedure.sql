USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPaymentRegisterTransaction_TEST]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[etlsp_cmdwh_penPaymentRegisterTransaction_TEST]    
as    
begin    
/************************************************************************************************************************************    
Author:         Linus Tor    
Date:           20130527    
Prerequisite:   Requires Penguin Data Model ETL successfully run.    
Description:    PaymentRegisterTransaction table contains payment transaction attributes.    
                This transformation adds essential key fields and implemented slow changing dimension technique to track    
                changes to the agency attributes.    
Change History:    
                20130528 - LT - Procedure created    
                20130617 - LS - TFS 7664/8556/8557, UK Penguin    
                20130618 - LT - Remove tblPaymentRegisterPolicy references    
                20130724 - LT - Removed redundant reference tblOutlet table    
                20130923 - LS - Add JV details    
                20140715 - LS - F 21325, use transaction, other session will not see data gets deleted until after it's replaced (intraday refresh)    
                20160321 - LT - Penguin 18.0, added US Penguin instance    
    		20210306, SS, CHG0034615 Add filter for BK.com  
			20220330 - VS - CHG0035761 change jv code char from 3 to 10
*************************************************************************************************************************************/    
    
    set nocount on    
    
    /* staging index */    
    exec etlsp_StagingIndex_Penguin    
    
    if object_id('etl_penPaymentRegisterTransaction') is not null    
        drop table etl_penPaymentRegisterTransaction    
    
    select    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        left(PrefixKey + convert(varchar, p.PaymentRegisterTransactionID), 41) as PaymentRegisterTransactionKey,    
        left(PrefixKey + convert(varchar, p.PaymentRegisterID), 41) as PaymentRegisterKey,    
        left(PrefixKey + convert(varchar, p.PaymentAllocationID), 41) as PaymentAllocationKey,    
        p.PaymentRegisterTransactionID,    
        p.PaymentRegisterID,    
        p.PaymentAllocationID,    
        p.Payer,    
        dbo.xfn_ConvertUTCtoLocal(p.BankDate, TimeZone) as BankDate,    
        p.BankDate as BankDateUTC,    
        p.BSB,    
        p.ChequeNumber,    
        p.Amount,    
        p.AmountType,    
        p.[Status],    
        p.Comment,    
        dbo.xfn_ConvertUTCtoLocal(p.CreateDateTime, Timezone) as CreateDateTime,    
        dbo.xfn_ConvertUTCtoLocal(p.UpdateDateTime, Timezone) as UpdateDateTime,    
        p.CreateDateTime as CreateDateTimeUTC,    
        p.UpdateDateTime as UpdateDateTimeUTC,    
        p.CreditNoteDepartmentID,    
        cn.CreditNoteDepartmentName,    
        cn.CreditNoteDepartmentCode,    
        p.JointVentureID,    
        jv.Code JVCode,    
        jv.Name JVDescription    
    into etl_penPaymentRegisterTransaction    
    from    
        dbo.penguin_tblPaymentRegisterTransaction_aucm p    
        inner join dbo.penguin_tblPaymentRegister_aucm pr on    
            p.PaymentRegisterID = pr.PaymentRegisterID    
        cross apply dbo.fn_GetDomainKeys(pr.DomainID, 'CM', 'AU') dk    
        outer apply    
        (    
            select top 1    
                [Name] CreditNoteDepartmentName,    
                [Code] CreditNoteDepartmentCode    
            from    
                dbo.penguin_tblCreditNoteDepartment_aucm    
            where    
                CreditNoteDepartmentID = p.CreditNoteDepartmentID    
        ) cn    
        left join penguin_tblJointVenture_aucm jv on    
            jv.JointVentureId = p.JointVentureId    
    
    union all    
    
    select    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        left(PrefixKey + convert(varchar, p.PaymentRegisterTransactionID), 41) as PaymentRegisterTransactionKey,    
        left(PrefixKey + convert(varchar, p.PaymentRegisterID), 41) as PaymentRegisterKey,    
        left(PrefixKey + convert(varchar, p.PaymentAllocationID), 41) as PaymentAllocationKey,    
        p.PaymentRegisterTransactionID,    
        p.PaymentRegisterID,    
        p.PaymentAllocationID,    
        p.Payer,    
        dbo.xfn_ConvertUTCtoLocal(p.BankDate, TimeZone) as BankDate,    
        p.BankDate as BankDateUTC,    
        p.BSB,    
        p.ChequeNumber,    
        p.Amount,    
        p.AmountType,    
        p.[Status],    
        p.Comment,    
        dbo.xfn_ConvertUTCtoLocal(p.CreateDateTime, Timezone) as CreateDateTime,    
        dbo.xfn_ConvertUTCtoLocal(p.UpdateDateTime, Timezone) as UpdateDateTime,    
        p.CreateDateTime as CreateDateTimeUTC,    
        p.UpdateDateTime as UpdateDateTimeUTC,    
        p.CreditNoteDepartmentID,    
        cn.CreditNoteDepartmentName,    
        cn.CreditNoteDepartmentCode,    
        p.JointVentureID,    
        jv.Code JVCode,    
        jv.Name JVDescription    
    from    
        dbo.penguin_tblPaymentRegisterTransaction_autp p    
        inner join dbo.penguin_tblPaymentRegister_autp pr on    
            p.PaymentRegisterID = pr.PaymentRegisterID    
        cross apply dbo.fn_GetDomainKeys(pr.DomainID, 'TIP', 'AU') dk    
        outer apply    
        (    
            select top 1    
                [Name] CreditNoteDepartmentName,    
                [Code] CreditNoteDepartmentCode    
            from    
                dbo.penguin_tblCreditNoteDepartment_autp    
            where    
                CreditNoteDepartmentID = p.CreditNoteDepartmentID    
        ) cn    
        left join penguin_tblJointVenture_autp jv on    
            jv.JointVentureId = p.JointVentureId    
    
    union all    
    
    select    
        CountryKey,    
        CompanyKey,    
        DomainKey,    
        left(PrefixKey + convert(varchar, p.PaymentRegisterTransactionID), 41) as PaymentRegisterTransactionKey,    
        left(PrefixKey + convert(varchar, p.PaymentRegisterID), 41) as PaymentRegisterKey,    
        left(PrefixKey + convert(varchar, p.PaymentAllocationID), 41) as PaymentAllocationKey,    
        p.PaymentRegisterTransactionID,    
        p.PaymentRegisterID,    
        p.PaymentAllocationID,    
        p.Payer,    
        dbo.xfn_ConvertUTCtoLocal(p.BankDate, TimeZone) as BankDate,    
        p.BankDate as BankDateUTC,    
        p.BSB,    
        p.ChequeNumber,    
        p.Amount,    
        p.AmountType,    
        p.[Status],    
        p.Comment,    
        dbo.xfn_ConvertUTCtoLocal(p.CreateDateTime, Timezone) as CreateDateTime,    
        dbo.xfn_ConvertUTCtoLocal(p.UpdateDateTime, Timezone) as UpdateDateTime,    
        p.CreateDateTime as CreateDateTimeUTC,    
        p.UpdateDateTime as UpdateDateTimeUTC,    
        p.CreditNoteDepartmentID,    
        cn.CreditNoteDepartmentName,    
        cn.CreditNoteDepartmentCode,    
        p.JointVentureID,    
        jv.Code JVCode,    
        jv.Name JVDescription    
    from    
        dbo.penguin_tblPaymentRegisterTransaction_ukcm p    
        inner join dbo.penguin_tblPaymentRegister_ukcm pr on    
            p.PaymentRegisterID = pr.PaymentRegisterID    
        cross apply dbo.fn_GetDomainKeys(pr.DomainID, 'CM', 'UK') dk    
        outer apply    
        (    
            select top 1    
                [Name] CreditNoteDepartmentName,    
                [Code] CreditNoteDepartmentCode    
            from    
                dbo.penguin_tblCreditNoteDepartment_ukcm    
            where    
                CreditNoteDepartmentID = p.CreditNoteDepartmentID    
        ) cn    
        left join penguin_tblJointVenture_ukcm jv on    
            jv.JointVentureId = p.JointVentureId    
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
        left(PrefixKey + convert(varchar, p.PaymentRegisterTransactionID), 41) as PaymentRegisterTransactionKey,    
        left(PrefixKey + convert(varchar, p.PaymentRegisterID), 41) as PaymentRegisterKey,    
        left(PrefixKey + convert(varchar, p.PaymentAllocationID), 41) as PaymentAllocationKey,    
        p.PaymentRegisterTransactionID,    
        p.PaymentRegisterID,    
        p.PaymentAllocationID,    
        p.Payer,    
        dbo.xfn_ConvertUTCtoLocal(p.BankDate, TimeZone) as BankDate,    
        p.BankDate as BankDateUTC,    
        p.BSB,    
        p.ChequeNumber,    
        p.Amount,    
        p.AmountType,    
        p.[Status],    
        p.Comment,    
        dbo.xfn_ConvertUTCtoLocal(p.CreateDateTime, Timezone) as CreateDateTime,    
        dbo.xfn_ConvertUTCtoLocal(p.UpdateDateTime, Timezone) as UpdateDateTime,    
        p.CreateDateTime as CreateDateTimeUTC,    
        p.UpdateDateTime as UpdateDateTimeUTC,    
        p.CreditNoteDepartmentID,    
        cn.CreditNoteDepartmentName,    
        cn.CreditNoteDepartmentCode,    
        p.JointVentureID,    
        jv.Code JVCode,    
        jv.Name JVDescription    
    from    
        dbo.penguin_tblPaymentRegisterTransaction_uscm p    
        inner join dbo.penguin_tblPaymentRegister_uscm pr on    
            p.PaymentRegisterID = pr.PaymentRegisterID    
        cross apply dbo.fn_GetDomainKeys(pr.DomainID, 'CM', 'US') dk    
        outer apply    
        (    
            select top 1    
                [Name] CreditNoteDepartmentName,    
                [Code] CreditNoteDepartmentCode    
            from    
                dbo.penguin_tblCreditNoteDepartment_uscm    
            where    
                CreditNoteDepartmentID = p.CreditNoteDepartmentID    
        ) cn    
        left join penguin_tblJointVenture_uscm jv on    
            jv.JointVentureId = p.JointVentureId    
    
    
    if object_id('[db-au-cmdwh].dbo.penPaymentRegisterTransaction') is null    
    begin    
    
        create table [db-au-cmdwh].[dbo].penPaymentRegisterTransaction    
        (    
            CountryKey varchar(2) null,    
            CompanyKey varchar(5) null,    
            DomainKey varchar(41) null,    
            PaymentRegisterTransactionKey varchar(41) null,    
            PaymentRegisterKey varchar(41) null,    
            PaymentAllocationKey varchar(41) null,    
            PaymentRegisterTransactionID int null,    
            PaymentRegisterID int null,    
            PaymentAllocationID int null,    
            Payer varchar(50) null,    
            BankDate datetime null,    
            BankDateUTC datetime null,    
            BSB varchar(10) null,    
            ChequeNumber varchar(30) null,    
            Amount money null,    
            AmountType varchar(15) null,    
            [Status] varchar(15) null,    
            Comment varchar(500) null,    
            CreateDateTime datetime null,    
            UpdateDateTime datetime null,    
            CreateDateTimeUTC datetime null,    
            UpdateDateTimeUTC datetime null,    
            CreditNoteDepartmentID int null,    
            CreditNoteDepartmentName varchar(55) null,    
            CreditNoteDepartmentCode varchar(3) null,    
            JointVentureID int null,    
            JVCode varchar(10),  --CHG0035761    
            JVDescription varchar(55)    
        )    
    
        create clustered index idx_penPaymentRegisterTransaction_PaymentRegisterTransactionKey on [db-au-cmdwh].dbo.penPaymentRegisterTransaction(PaymentRegisterTransactionKey)    
        create index idx_penPaymentRegisterTransaction_CountryKey on [db-au-cmdwh].dbo.penPaymentRegisterTransaction(CountryKey)    
        create index idx_penPaymentRegisterTransaction_PaymentRegisterKey on [db-au-cmdwh].dbo.penPaymentRegisterTransaction(PaymentRegisterKey)    
        create index idx_penPaymentRegisterTransaction_PaymentAllocationKeyKey on [db-au-cmdwh].dbo.penPaymentRegisterTransaction(PaymentAllocationKey)    
            
    end    
        
        
    begin transaction penPaymentRegisterTransaction    
        
    begin try    
    
        delete a    
        from    
            [db-au-cmdwh].dbo.penPaymentRegisterTransaction a    
            inner join etl_penPaymentRegisterTransaction b on    
                a.PaymentRegisterTransactionKey = b.PaymentRegisterTransactionKey    
    
        insert [db-au-cmdwh].dbo.penPaymentRegisterTransaction with(tablockx)    
        (    
            CountryKey,    
            CompanyKey,    
            DomainKey,    
            PaymentRegisterTransactionKey,    
            PaymentRegisterKey,    
            PaymentAllocationKey,    
            PaymentRegisterTransactionID,    
            PaymentRegisterID,    
            PaymentAllocationID,    
            Payer,    
            BankDate,    
            BankDateUTC,    
            BSB,    
            ChequeNumber,    
            Amount,    
            AmountType,    
            [Status],    
            Comment,    
            CreateDateTime,    
            UpdateDateTime,    
            CreateDateTimeUTC,    
            UpdateDateTimeUTC,    
            CreditNoteDepartmentID,    
            CreditNoteDepartmentName,    
            CreditNoteDepartmentCode,    
            JointVentureID,    
            JVCode,    
            JVDescription    
        )    
        select    
            CountryKey,    
            CompanyKey,    
            DomainKey,    
            PaymentRegisterTransactionKey,    
            PaymentRegisterKey,    
            PaymentAllocationKey,    
            PaymentRegisterTransactionID,    
            PaymentRegisterID,    
            PaymentAllocationID,    
            Payer,    
            BankDate,    
            BankDateUTC,    
            BSB,    
            ChequeNumber,    
            Amount,    
            AmountType,    
            [Status],    
            Comment,    
            CreateDateTime,    
            UpdateDateTime,    
            CreateDateTimeUTC,    
            UpdateDateTimeUTC,    
            CreditNoteDepartmentID,    
            CreditNoteDepartmentName,    
            CreditNoteDepartmentCode,    
            JointVentureID,    
            JVCode,    
            JVDescription    
        from    
            etl_penPaymentRegisterTransaction    
    
    end try    
        
    begin catch    
        
        if @@trancount > 0    
            rollback transaction penPaymentRegisterTransaction    
                
        exec syssp_genericerrorhandler 'penPaymentRegisterTransaction data refresh failed'    
            
    end catch        
    
    if @@trancount > 0    
        commit transaction penPaymentRegisterTransaction    
            
end    



GO
