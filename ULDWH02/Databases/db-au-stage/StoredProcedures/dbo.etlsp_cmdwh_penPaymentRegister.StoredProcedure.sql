USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPaymentRegister]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
CREATE procedure [dbo].[etlsp_cmdwh_penPaymentRegister]  
as  
begin  
  
  
/************************************************************************************************************************************  
Author:         Linus Tor  
Date:           20130527  
Prerequisite:   Requires Penguin Data Model ETL successfully run.  
Description:    PaymentRegister table contains payment common attributes.  
                This transformation adds essential key fields and implemented slow changing dimension technique to track  
                changes to the agency attributes.  
Change History:  
                20130528 - LT - Procedure created  
                20130617 - LS - TFS 7664/8556/8557, UK Penguin  
                20130724 - LT - Added DomainID, and removed redundant reference to tblOutlet table  
                20130830 - LS - Add Comment  
                20140715 - LS - F 21325, use transaction, other session will not see data gets deleted until after it's replaced (intraday refresh)  
                20160321 - LT - Penguin 18.0, Added US Penguin instance  
  		20210306, SS, CHG0034615 Add filter for BK.com  
*************************************************************************************************************************************/  
  
    set nocount on  
  
    /* staging index */  
    exec etlsp_StagingIndex_Penguin  
  
    if object_id('etl_penPaymentRegister') is not null  
        drop table etl_penPaymentRegister  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        left(PrefixKey + convert(varchar, p.PaymentRegisterID), 41) as PaymentRegisterKey,  
        left(PrefixKey + convert(varchar, p.OutletID), 41) as OutletKey,  
        left(PrefixKey + convert(varchar, p.CRMUserID), 41) as CRMUserKey,  
        left(PrefixKey + convert(varchar, p.BankAccountID), 41) as BankAccountKey,  
        p.PaymentRegisterID,  
        p.OutletID,  
        p.CRMUserID,  
        p.BankAccountID,  
        p.[Status] as PaymentStatus,  
        p.PaymentTypeID,  
        pyt.PaymentType,  
        pyt.PaymentCode,  
        p.[Source] as PaymentSource,  
        p.Comment,  
        dbo.xfn_ConvertUTCtoLocal(p.CreateDateTime, TimeZone) as PaymentCreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(p.UpdateDateTime, TimeZone) as PaymentUpdateDateTime,  
        p.CreateDateTime as PaymentCreateDateTimeUTC,  
        p.UpdateDateTime as PaymentUpdateDateTimeUTC,  
        p.DomainID,  
        null as TripsAccount  
    into etl_penPaymentRegister  
    from  
        dbo.penguin_tblPaymentRegister_aucm p  
        cross apply dbo.fn_GetDomainKeys(p.DomainID, 'CM', 'AU') dk  
        outer apply  
        (  
            select top 1  
                [Code] PaymentCode,  
                [Name] PaymentType  
            from  
                penguin_tblPaymentType_aucm  
            where  
                PaymentTypeID = p.PaymentTypeID  
        ) pyt  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        left(PrefixKey + convert(varchar, p.PaymentRegisterID), 41) as PaymentRegisterKey,  
        left(PrefixKey + convert(varchar, p.OutletID), 41) as OutletKey,  
        left(PrefixKey + convert(varchar, p.CRMUserID), 41) as CRMUserKey,  
        left(PrefixKey + convert(varchar, p.BankAccountID), 41) as BankAccountKey,  
        p.PaymentRegisterID,  
        p.OutletID,  
        p.CRMUserID,  
        p.BankAccountID,  
        p.[Status] as PaymentStatus,  
        p.PaymentTypeID,  
        pyt.PaymentType,  
        pyt.PaymentCode,  
        p.[Source] as PaymentSource,  
        p.Comment,  
        dbo.xfn_ConvertUTCtoLocal(p.CreateDateTime, TimeZone) as PaymentCreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(p.UpdateDateTime, TimeZone) as PaymentUpdateDateTime,  
        p.CreateDateTime as PaymentCreateDateTimeUTC,  
        p.UpdateDateTime as PaymentUpdateDateTimeUTC,  
        p.DomainID,  
        null as TripsAccount  
    from  
        dbo.penguin_tblPaymentRegister_autp p  
        cross apply dbo.fn_GetDomainKeys(p.DomainID, 'TIP', 'AU') dk  
        outer apply  
        (  
            select top 1  
                [Code] PaymentCode,  
                [Name] PaymentType  
            from  
                penguin_tblPaymentType_autp  
            where  
                PaymentTypeID = p.PaymentTypeID  
        ) pyt  
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        left(PrefixKey + convert(varchar, p.PaymentRegisterID), 41) as PaymentRegisterKey,  
        left(PrefixKey + convert(varchar, p.OutletID), 41) as OutletKey,  
        left(PrefixKey + convert(varchar, p.CRMUserID), 41) as CRMUserKey,  
        left(PrefixKey + convert(varchar, p.BankAccountID), 41) as BankAccountKey,  
        p.PaymentRegisterID,  
        p.OutletID,  
        p.CRMUserID,  
        p.BankAccountID,  
        p.[Status] as PaymentStatus,  
        p.PaymentTypeID,  
        pyt.PaymentType,  
        pyt.PaymentCode,  
        p.[Source] as PaymentSource,  
        p.Comment,  
        dbo.xfn_ConvertUTCtoLocal(p.CreateDateTime, TimeZone) as PaymentCreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(p.UpdateDateTime, TimeZone) as PaymentUpdateDateTime,  
        p.CreateDateTime as PaymentCreateDateTimeUTC,  
        p.UpdateDateTime as PaymentUpdateDateTimeUTC,  
        p.DomainID,  
        null as TripsAccount  
    from  
        dbo.penguin_tblPaymentRegister_ukcm p  
        cross apply dbo.fn_GetDomainKeys(p.DomainID, 'CM', 'UK') dk  
        outer apply  
        (  
            select top 1  
                [Code] PaymentCode,  
                [Name] PaymentType  
            from  
                penguin_tblPaymentType_ukcm  
            where  
                PaymentTypeID = p.PaymentTypeID  
        ) pyt  
	where p.OutletID not in (select OutletId from penguin_tblOutlet_ukcm where AlphaCode like 'BK%')
  
    union all  
  
    select  
        CountryKey,  
        CompanyKey,  
        DomainKey,  
        left(PrefixKey + convert(varchar, p.PaymentRegisterID), 41) as PaymentRegisterKey,  
        left(PrefixKey + convert(varchar, p.OutletID), 41) as OutletKey,  
        left(PrefixKey + convert(varchar, p.CRMUserID), 41) as CRMUserKey,  
        left(PrefixKey + convert(varchar, p.BankAccountID), 41) as BankAccountKey,  
        p.PaymentRegisterID,  
        p.OutletID,  
        p.CRMUserID,  
        p.BankAccountID,  
        p.[Status] as PaymentStatus,  
        p.PaymentTypeID,  
        pyt.PaymentType,  
        pyt.PaymentCode,  
        p.[Source] as PaymentSource,  
        p.Comment,  
        dbo.xfn_ConvertUTCtoLocal(p.CreateDateTime, TimeZone) as PaymentCreateDateTime,  
        dbo.xfn_ConvertUTCtoLocal(p.UpdateDateTime, TimeZone) as PaymentUpdateDateTime,  
        p.CreateDateTime as PaymentCreateDateTimeUTC,  
        p.UpdateDateTime as PaymentUpdateDateTimeUTC,  
        p.DomainID,  
        null as TripsAccount  
    from  
        dbo.penguin_tblPaymentRegister_uscm p  
        cross apply dbo.fn_GetDomainKeys(p.DomainID, 'CM', 'US') dk  
        outer apply  
        (  
            select top 1  
                [Code] PaymentCode,  
                [Name] PaymentType  
            from  
                penguin_tblPaymentType_uscm  
            where  
                PaymentTypeID = p.PaymentTypeID  
        ) pyt  
  
  
    if object_id('[db-au-cmdwh].dbo.penPaymentRegister') is null  
    begin  
  
        create table [db-au-cmdwh].[dbo].penPaymentRegister  
        (  
            [CountryKey] [varchar](2) null,  
            [CompanyKey] [varchar](5) null,  
            [DomainKey] [varchar](41) null,  
            [PaymentRegisterKey] [varchar](41) null,  
            [OutletKey] [varchar](41) null,  
            [CRMUserKey] [varchar](41) null,  
            [BankAccountKey] [varchar](41) null,  
            [PaymentRegisterID] [int] null,  
            [OutletID] [int] null,  
            [CRMUserID] [int] null,  
            [BankAccountID] [int] null,  
            [PaymentStatus] [varchar](15) null,  
            [PaymentTypeID] [int] null,  
            [PaymentType] [varchar](55) null,  
            [PaymentCode] [varchar](3) null,  
            [PaymentSource] [varchar](50) null,  
            [Comment] [varchar](500) null,  
            [PaymentCreateDateTime] [datetime] null,  
            [PaymentUpdateDateTime] [datetime] null,  
            [PaymentCreateDateTimeUTC] [datetime] null,  
            [PaymentUpdateDateTimeUTC] [datetime] null,  
            [DomainID] [int] null,  
            [TripsAccount] [varchar](4) null  
        )  
        create clustered index idx_penPaymentRegister_PaymentRegisterKey on [db-au-cmdwh].dbo.penPaymentRegister(PaymentRegisterKey)  
        create index idx_penPaymentRegister_CountryKey on [db-au-cmdwh].dbo.penPaymentRegister(CountryKey)  
        create index idx_penPaymentRegister_OutletKey on [db-au-cmdwh].dbo.penPaymentRegister(OutletKey)  
        create index idx_penPaymentRegister_CRMUserKey on [db-au-cmdwh].dbo.penPaymentRegister(CRMUserKey)  
        create index idx_penPaymentRegister_BankAccountKey on [db-au-cmdwh].dbo.penPaymentRegister(BankAccountKey)  
  
    end  
      
      
    begin transaction penPaymentRegister  
      
    begin try  
  
        delete a  
        from  
            [db-au-cmdwh].dbo.penPaymentRegister a  
            inner join etl_penPaymentRegister b on  
                a.PaymentRegisterKey = b.PaymentRegisterKey  
  
        insert [db-au-cmdwh].dbo.penPaymentRegister with(tablockx)  
        (  
            [CountryKey],  
            [CompanyKey],  
            [DomainKey],  
            [PaymentRegisterKey],  
            [OutletKey],  
            [CRMUserKey],  
            [BankAccountKey],  
            [PaymentRegisterID],  
            [OutletID],  
            [CRMUserID],  
            [BankAccountID],  
            [PaymentStatus],  
            [PaymentTypeID],  
            [PaymentType],  
            [PaymentCode],  
            [PaymentSource],  
            [Comment],  
            [PaymentCreateDateTime],  
            [PaymentUpdateDateTime],  
            [PaymentCreateDateTimeUTC],  
            [PaymentUpdateDateTimeUTC],  
            [DomainID],  
            [TripsAccount]  
        )  
        select  
            [CountryKey],  
            [CompanyKey],  
            [DomainKey],  
            [PaymentRegisterKey],  
            [OutletKey],  
            [CRMUserKey],  
            [BankAccountKey],  
            [PaymentRegisterID],  
            [OutletID],  
            [CRMUserID],  
            [BankAccountID],  
            [PaymentStatus],  
            [PaymentTypeID],  
            [PaymentType],  
            [PaymentCode],  
            [PaymentSource],  
            [Comment],  
            [PaymentCreateDateTime],  
            [PaymentUpdateDateTime],  
            [PaymentCreateDateTimeUTC],  
            [PaymentUpdateDateTimeUTC],  
            [DomainID],  
            [TripsAccount]  
        from  
            etl_penPaymentRegister  
  
    end try  
      
    begin catch  
      
        if @@trancount > 0  
            rollback transaction penPaymentRegister  
              
        exec syssp_genericerrorhandler 'penPaymentRegister data refresh failed'  
          
    end catch      
  
    if @@trancount > 0  
        commit transaction penPaymentRegister  
  
end  
  
GO
