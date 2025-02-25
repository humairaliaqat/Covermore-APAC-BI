USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_ETL037_Bank_Migration_penBankAccount]    Script Date: 24/02/2025 5:08:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_ETL037_Bank_Migration_penBankAccount] 
    @Country varchar(10) = ''
    
as
begin
--TRIPS BankAccount table data migration to PENGUIN
--Transform and migration BankAccount data to penBankAccount
--BankAccountKey will have a 'T' prefix to denote trips migrated data.
--
--
--2013-08-02, LS,   TRIPS Bank Account is no longer needed, it's already available on penOutlet
--                  penBankAccount should hold CM's bank account

    set nocount on

    insert into [db-au-cmdwh]..penBankAccount
    (
        CountryKey,
        CompanyKey,
        DomainKey,
        BankAccountKey,
        AccountName,
        AccountCode
    )
    select distinct
        o.CountryKey,
        o.CompanyKey,
        o.DomainKey,
        o.CountryKey + '-T' + o.CompanyKey + '-' + upper(br.Account) BankAccountKey,
        upper(br.Account) AccountName,
        upper(br.Account) AccountCode
    from
        [db-au-cmdwh]..BankReturn br
        inner join [db-au-cmdwh]..penOutlet o on
            o.CountryKey = br.CountryKey and
            o.OutletStatus = 'Current' and
            o.AlphaCode = br.AgencyCode
        left join [db-au-cmdwh]..penBankAccount b on
            b.BankAccountKey = o.CountryKey + '-' + o.CompanyKey + '-' + upper(br.Account)
    where
        br.Account is not null and
        b.BankAccountKey is null and
        not exists
        (
            select null
            from
                [db-au-cmdwh].dbo.penBankAccount b
            where
                b.BankAccountKey = o.CountryKey + '-T' + o.CompanyKey + '-' + upper(br.Account)
        )

end
GO
