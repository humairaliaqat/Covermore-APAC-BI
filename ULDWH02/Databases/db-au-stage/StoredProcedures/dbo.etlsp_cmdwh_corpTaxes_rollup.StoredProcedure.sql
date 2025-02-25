USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpTaxes_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[etlsp_cmdwh_corpTaxes_rollup]
as
begin

/*
20130114 - LS - Case 18123, Fix UK Data
20170504 - LL - INC0030461, corporate application fix gone wrong
                override AccountingPeriod to be null for every A record created after 20170331 or accounting period after 20170331
*/

    set nocount on

    /*************************************************************/
    --combine quotes from AU, NZ, UK into one table
    /*************************************************************/

    if object_id('[db-au-stage].dbo.etl_corpTaxes') is not null
        drop table [db-au-stage].dbo.etl_corpTaxes

    select
        'AU' as CountryKey,
        left('AU-' + cast(t.TaxID as varchar),10) as TaxKey,
        left('AU-' + cast(t.QtID as varchar),10) as QuoteKey,
        left('AU-' + cast(t.ItemID as varchar),10) as ItemKey,
        t.TaxID,
        t.QtID as QuoteID,
        t.ItemID,
        t.CreatedDt as CreateDate,
        t.ActPeriod as AccountingPeriod,
        t.ItemType,
        t.PropBal,
        t.DomPremIncGST,
        t.DomStamp,
        t.IntStamp,
        t.GSTGross,
        t.UWSaleExGST,
        t.GSTAgtComm,
        t.AgtCommExGST,
        t.GSTCMComm,
        t.CMCommExGST
    into [db-au-stage].dbo.etl_corpTaxes
    from
        [db-au-stage].dbo.corp_tblTaxes_au t

    union all

    select
        'NZ' as CountryKey,
        left('NZ-' + cast(t.TaxID as varchar),10) as TaxKey,
        left('NZ-' + cast(t.QtID as varchar),10) as QuoteKey,
        left('NZ-' + cast(t.ItemID as varchar),10) as ItemKey,
        t.TaxID,
        t.QtID as QuoteID,
        t.ItemID,
        t.CreatedDt as CreateDate,
        t.ActPeriod as AccountingPeriod,
        t.ItemType,
        t.PropBal,
        t.DomPremIncGST,
        t.DomStamp,
        t.IntStamp,
        t.GSTGross,
        t.UWSaleExGST,
        t.GSTAgtComm,
        t.AgtCommExGST,
        t.GSTCMComm,
        t.CMCommExGST
    from
        [db-au-stage].dbo.corp_tblTaxes_nz t

    union all

    select
        'UK' as CountryKey,
        left('UK-' + cast(t.DaysPaidID as varchar),10) as TaxKey,
        left('UK-' + cast(t.QtID as varchar),10) as QuoteKey,
        left('UK-' + cast(t.DaysPaidID as varchar),10) as ItemKey,
        t.DaysPaidID,
        t.QtID as QuoteID,
        t.DaysPaidID ItemID,
        t.CreatedDt as CreateDate,
        dateadd(day, -1, dateadd(month, 1, (convert(varchar(8), t.CreatedDt, 120) + '01'))) as AccountingPeriod,
        'DEST' ItemType,
        t.PropBal,
        0 DomPremIncGST,
        0 DomStamp,
        0 IntStamp,
        case
            when (t.CalcLoad + t.AgtComm) = 0 then 0
            else t.IPT * 1.0 / (t.CalcLoad + t.AgtComm) * t.CalcLoad
        end GSTGross,
        t.CalcLoad +
        (
            t.AgtComm +
            case
                when (t.CalcLoad + t.AgtComm) = 0 then 0
                else t.IPT * 1.0 / (t.CalcLoad + t.AgtComm) * t.AgtComm
            end
        ) UWSaleExGST,
        case
            when (t.CalcLoad + t.AgtComm) = 0 then 0
            else t.IPT * 1.0 / (t.CalcLoad + t.AgtComm) * t.AgtComm
        end GSTAgtComm,
        t.AgtComm AgtCommExGST,
        0 GSTCMComm,
        0 CMCommExGST
    from
        [db-au-stage].dbo.corp_tblDaysPaid_uk t

    /*************************************************************/
    --delete existing quotes or create table if table doesnt exist
    /*************************************************************/

    if object_id('[db-au-cmdwh].dbo.corpTaxes') is null
    begin

        create table [db-au-cmdwh].dbo.corpTaxes
        (
            CountryKey varchar(2) NOT NULL,
            TaxKey varchar(10) NULL,
            QuoteKey varchar(10) NULL,
            ItemKey varchar(10) NULL,
            TaxID int NOT NULL,
            QuoteID int NULL,
            ItemID int NULL,
            CreateDate datetime NULL,
            AccountingPeriod datetime NULL,
            ItemType varchar(50) NULL,
            PropBal char(1) NULL,
            DomPremIncGST money NULL,
            DomStamp money NULL,
            IntStamp money NULL,
            GSTGross money NULL,
            UWSaleExGST money NULL,
            GSTAgtComm money NULL,
            AgtCommExGST money NULL,
            GSTCMComm money NULL,
            CMCommExGST money NULL
        )

        create clustered index idx_corpTaxes_QuoteKey on [db-au-cmdwh].dbo.corpTaxes(QuoteKey)
        create index idx_corpTaxes_AccountingPeriod on [db-au-cmdwh].dbo.corpTaxes(AccountingPeriod)
        create index idx_corpTaxes_CountryKey on [db-au-cmdwh].dbo.corpTaxes(CountryKey)
        create index idx_corpTaxes_TaxKey on [db-au-cmdwh].dbo.corpTaxes(TaxKey)
        create index idx_corpTaxes_ItemKey on [db-au-cmdwh].dbo.corpTaxes(ItemKey)

    end
    else
        truncate table [db-au-cmdwh].dbo.corpTaxes


    /*************************************************************/
    -- Transfer data from [db-au-stage].dbo.etl_corpTaxes to [db-au-cmdwh].dbo.corpTaxes
    /*************************************************************/

    insert into [db-au-cmdwh].dbo.corpTaxes with (tablock)
    (
        CountryKey,
        TaxKey,
        QuoteKey,
        ItemKey,
        TaxID,
        QuoteID,
        ItemID,
        CreateDate,
        AccountingPeriod,
        ItemType,
        PropBal,
        DomPremIncGST,
        DomStamp,
        IntStamp,
        GSTGross,
        UWSaleExGST,
        GSTAgtComm,
        AgtCommExGST,
        GSTCMComm,
        CMCommExGST
    )
    select
        CountryKey,
        TaxKey,
        QuoteKey,
        ItemKey,
        TaxID,
        QuoteID,
        ItemID,
        CreateDate,
        case
            when PropBal = 'A' and CreateDate >= '2017-03-31' then null
            when PropBal = 'A' and AccountingPeriod >= '2017-03-31' then null
            else AccountingPeriod 
        end AccountingPeriod,
        ItemType,
        PropBal,
        DomPremIncGST,
        DomStamp,
        IntStamp,
        GSTGross,
        UWSaleExGST,
        GSTAgtComm,
        AgtCommExGST,
        GSTCMComm,
        CMCommExGST
    from
        [db-au-stage].dbo.etl_corpTaxes

end
GO
