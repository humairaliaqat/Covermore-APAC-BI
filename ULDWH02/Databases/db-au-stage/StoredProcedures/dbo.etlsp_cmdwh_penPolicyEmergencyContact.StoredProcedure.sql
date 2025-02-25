USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_penPolicyEmergencyContact]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_penPolicyEmergencyContact]
as
begin
/************************************************************************************************************************************
Author:         Linus Tor
Date:           20180926
Prerequisite:   Requires Penguin Data Model ETL successfully run.
Description:    Transform table and adding essential key fields

Change History:
                20180926 - LT - Procedure created

*************************************************************************************************************************************/

    /* staging index */
    exec etlsp_StagingIndex_Penguin

    set nocount on

    if object_id('etl_penPolicyEmergencyContact') is not null
        drop table etl_penPolicyEmergencyContact

    select
        CountryKey,
        CompanyKey,
		PrefixKey + convert(varchar, p.PolicyID) PolicyKey,
		PrefixKey + convert(varchar, pt.ID) PolicyTransactionKey,
        p.DomainID,
		pec.PolicyNumber,
		pec.Title,
		pec.FirstName,
		pec.SurName,
		pec.EmailAddress,
		pec.MobilePhone,
		pec.WorkPhone,		
		dbo.xfn_ConvertUTCtoLocal(pec.CreatedDate, TimeZone) CreatedDate,
		pec.CreatedDate as CreatedDateUTC
    into etl_penPolicyEmergencyContact
    from
        penguin_tblPolicyEmergencyContact_aucm pec
		inner join penguin_tblPolicy_aucm p on pec.PolicyNumber = p.PolicyNumber
		inner join penguin_tblPolicyTransaction_aucm pt on p.PolicyID = pt.PolicyID
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'AU') dk
       
    union all

    select
        CountryKey,
        CompanyKey,
		PrefixKey + convert(varchar, p.PolicyID) PolicyKey,
		PrefixKey + convert(varchar, pt.ID) PolicyTransactionKey,
        p.DomainID,
		pec.PolicyNumber,
		pec.Title,
		pec.FirstName,
		pec.SurName,
		pec.EmailAddress,
		pec.MobilePhone,
		pec.WorkPhone,		
		dbo.xfn_ConvertUTCtoLocal(pec.CreatedDate, TimeZone) CreatedDate,
		pec.CreatedDate as CreatedDateUTC
    from
        penguin_tblPolicyEmergencyContact_autp pec
		inner join penguin_tblPolicy_autp p on pec.PolicyNumber = p.PolicyNumber
		inner join penguin_tblPolicyTransaction_autp pt on p.PolicyID = pt.PolicyID
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'AU') dk

    union all

    select
        CountryKey,
        CompanyKey,
		PrefixKey + convert(varchar, p.PolicyID) PolicyKey,
		PrefixKey + convert(varchar, pt.ID) PolicyTransactionKey,
        p.DomainID,
		pec.PolicyNumber,
		pec.Title,
		pec.FirstName,
		pec.SurName,
		pec.EmailAddress,
		pec.MobilePhone,
		pec.WorkPhone,		
		dbo.xfn_ConvertUTCtoLocal(pec.CreatedDate, TimeZone) CreatedDate,
		pec.CreatedDate as CreatedDateUTC
    from
        penguin_tblPolicyEmergencyContact_ukcm pec
		inner join penguin_tblPolicy_ukcm p on pec.PolicyNumber = p.PolicyNumber
		inner join penguin_tblPolicyTransaction_ukcm pt on p.PolicyID = pt.PolicyID
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'UK') dk

    union all

    select
        CountryKey,
        CompanyKey,
		PrefixKey + convert(varchar, p.PolicyID) PolicyKey,
		PrefixKey + convert(varchar, pt.ID) PolicyTransactionKey,
        p.DomainID,
		pec.PolicyNumber,
		pec.Title,
		pec.FirstName,
		pec.SurName,
		pec.EmailAddress,
		pec.MobilePhone,
		pec.WorkPhone,		
		dbo.xfn_ConvertUTCtoLocal(pec.CreatedDate, TimeZone) CreatedDate,
		pec.CreatedDate as CreatedDateUTC
    from
        penguin_tblPolicyEmergencyContact_uscm pec
		inner join penguin_tblPolicy_uscm p on pec.PolicyNumber = p.PolicyNumber
		inner join penguin_tblPolicyTransaction_uscm pt on p.PolicyID = pt.PolicyID
        cross apply dbo.fn_GetPolicyDomainKeys(pt.PolicyID, pt.CRMUserID, pt.ConsultantID, 'CM', 'US') dk


    if object_id('[db-au-cmdwh].dbo.penPolicyEmergencyContact') is null
    begin

        create table [db-au-cmdwh].dbo.penPolicyEmergencyContact
        (
            [CountryKey] varchar(2) not null,
            [CompanyKey] varchar(5) not null,
			[PolicyKey] varchar(41) null,
            [PolicyTransactionKey] varchar(41) null,
			[PolicyNumber] [varchar](50) NULL,
			[Title] [nvarchar](50) NULL,
			[FirstName] [nvarchar](100) NULL,
			[SurName] [nvarchar](100) NULL,
			[EmailAddress] [nvarchar](255) NULL,
			[MobilePhone] [varchar](50) NULL,
			[WorkPhone] [varchar](50) NULL,
			[CreatedDate] [datetime] NULL,
			[CreatedDateUTC] [datetime] NULL
        )

        create clustered index idx_penPolicEmergencyContact_PolicyTransactionKey on [db-au-cmdwh].dbo.penPolicyEmergencyContact(PolicyTransactionKey)
        create nonclustered index idx_penPolicyEmergencyContact_PolicyKey on [db-au-cmdwh].dbo.penPolicyEmergencyContact(PolicyKey,PolicyNumber)

    end
    
    
    begin transaction penPolicyEmergencyContact
    
    begin try

        delete a
        from
            [db-au-cmdwh].dbo.penPolicyEmergencyContact a
            inner join etl_penPolicyEmergencyContact b on
                a.PolicyTransactionKey = b.PolicyTransactionKey

        insert into [db-au-cmdwh].dbo.penPolicyEmergencyContact with(tablockx)
        (
            [CountryKey],
            [CompanyKey],
			[PolicyKey],
            [PolicyTransactionKey],
			[PolicyNumber],
			[Title],
			[FirstName],
			[SurName],
			[EmailAddress],
			[MobilePhone],
			[WorkPhone],
			[CreatedDate],
			[CreatedDateUTC]
        )
        select
            [CountryKey],
            [CompanyKey],
			[PolicyKey],
            [PolicyTransactionKey],
			[PolicyNumber],
			[Title],
			[FirstName],
			[SurName],
			[EmailAddress],
			[MobilePhone],
			[WorkPhone],
			[CreatedDate],
			[CreatedDateUTC]
        from
            etl_penPolicyEmergencyContact

    end try
    
    begin catch
    
        if @@trancount > 0
            rollback transaction penPolicyEmergencyContact
            
        exec syssp_genericerrorhandler 'penPolicyEmergencyContact data refresh failed'
        
    end catch    

    if @@trancount > 0
        commit transaction penPolicyEmergencyContact

end

GO
