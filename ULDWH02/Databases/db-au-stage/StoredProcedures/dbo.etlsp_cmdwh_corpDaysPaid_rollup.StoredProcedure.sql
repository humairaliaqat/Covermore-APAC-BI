USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpDaysPaid_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_corpDaysPaid_rollup]
as
begin

/*
20130114 - LS - Case 18123, Fix UK Data
*/

    set nocount on

    /*************************************************************/
    --combine days paid from AU, NZ, UK into one table
    /*************************************************************/

    if object_id('[db-au-stage].dbo.etl_corpDaysPaid') is not null
        drop table [db-au-stage].dbo.etl_corpDaysPaid

    select
        'AU' as CountryKey,
        left('AU-' + cast(d.DaysPaidID as varchar),10) as DaysPaidKey,
        left('AU-' + cast(d.QtID as varchar),10) as QuoteKey,
        left('AU-' + cast(d.BankRec as varchar),10) as BankRecordKey,
        d.DaysPaidID,
        d.QtID as QuoteID,
        d.CreatedDt as CreateDate,
        d.IssuedDt as IssuedDate,
        d.PropBal,
        d.CalcLoad,
        d.VolDisc,
        d.NewPolDisc,
        d.XSDisc,
        d.MinPremPenalty,
        d.InterimPrem,
        d.CMCommDisc,
        d.DestLoad,
        d.AssistFees,
        d.AgtComm,
        d.CMComm,
        d.DomRatio,
        d.BankRec as BankRecord
    into [db-au-stage].dbo.etl_corpDaysPaid
    from
        [db-au-stage].dbo.corp_tblDaysPaid_au d

    union all

    select
        'NZ' as CountryKey,
        left('NZ-' + cast(d.DaysPaidID as varchar),10) as DaysPaidKey,
        left('NZ-' + cast(d.QtID as varchar),10) as QuoteKey,
        left('NZ-' + cast(d.BankRec as varchar),10) as BankRecordKey,
        d.DaysPaidID,
        d.QtID as QuoteID,
        d.CreatedDt as CreateDate,
        d.IssuedDt as IssuedDate,
        d.PropBal,
        d.CalcLoad,
        d.VolDisc,
        d.NewPolDisc,
        d.XSDisc,
        d.MinPremPenalty,
        d.InterimPrem,
        d.CMCommDisc,
        d.DestLoad,
        d.AssistFees,
        d.AgtComm,
        d.CMComm,
        d.DomRatio,
        d.BankRec as BankRecord
    from
        [db-au-stage].dbo.corp_tblDaysPaid_nz d

    union all

    select
        'UK' as CountryKey,
        left('UK-' + cast(d.DaysPaidID as varchar),10) as DaysPaidKey,
        left('UK-' + cast(d.QtID as varchar),10) as QuoteKey,
        left('UK-' + cast(d.BankRec as varchar),10) as BankRecordKey,
        d.DaysPaidID,
        d.QtID as QuoteID,
        d.CreatedDt as CreateDate,
        d.IssuedDt as IssuedDate,
        d.PropBal,
        d.CalcLoad,
        null as VolDisc,
        null as NewPolDisc,
        null as XSDisc,
        null as MinPremPenalty,
        null as InterimPrem,
        null as CMCommDisc,
        d.DestLoad,
        null as AssistFees,
        d.AgtComm,
        null as CMComm,
        null as DomRatio,
        d.BankRec
    from
        [db-au-stage].dbo.corp_tblDaysPaid_uk d


    if object_id('[db-au-cmdwh].dbo.corpDaysPaid') is null
    begin
        create table [db-au-cmdwh].dbo.corpDaysPaid
        (
            CountryKey varchar(2) NOT NULL,
            DaysPaidKey varchar(10) NULL,
            QuoteKey varchar(10) NULL,
            BankRecordKey varchar(10) NULL,
            DaysPaidID int NOT NULL,
            QuoteID int NULL,
            CreateDate datetime NULL,
            IssuedDate datetime NULL,
            PropBal char(1) NULL,
            CalcLoad money NULL,
            VolDisc money NULL,
            NewPolDisc money NULL,
            XSDisc money NULL,
            MinPremPenalty money NULL,
            InterimPrem money NULL,
            CMCommDisc money NULL,
            DestLoad money NULL,
            AssistFees money NULL,
            AgtComm money NULL,
            CMComm money NULL,
            DomRatio real NULL,
            BankRecord int NULL
        )

        create clustered index idx_corpDaysPaid_QuoteKey on [db-au-cmdwh].dbo.corpDaysPaid(QuoteKey)
        create index idx_corpDaysPaid_CountryKey on [db-au-cmdwh].dbo.corpDaysPaid(CountryKey)
        create index idx_corpDaysPaid_DaysPaidKey on [db-au-cmdwh].dbo.corpDaysPaid(DaysPaidKey)
        create index idx_corpDaysPaid_BankRecordKey on [db-au-cmdwh].dbo.corpDaysPaid(BankRecordKey)

    end
    else
        truncate table [db-au-cmdwh].dbo.corpDaysPaid


    /*************************************************************/
    -- Transfer data from [db-au-stage].dbo.etl_corpDaysPaid to [db-au-cmdwh].dbo.corpDaysPaid
    /*************************************************************/

    insert into [db-au-cmdwh].dbo.corpDaysPaid with (tablock)
    (
        CountryKey,
        DaysPaidKey,
        QuoteKey,
        BankRecordKey,
        DaysPaidID,
        QuoteID,
        CreateDate,
        IssuedDate,
        PropBal,
        CalcLoad,
        VolDisc,
        NewPolDisc,
        XSDisc,
        MinPremPenalty,
        InterimPrem,
        CMCommDisc,
        DestLoad,
        AssistFees,
        AgtComm,
        CMComm,
        DomRatio,
        BankRecord
    )
    select
        CountryKey,
        DaysPaidKey,
        QuoteKey,
        BankRecordKey,
        DaysPaidID,
        QuoteID,
        CreateDate,
        IssuedDate,
        PropBal,
        CalcLoad,
        VolDisc,
        NewPolDisc,
        XSDisc,
        MinPremPenalty,
        InterimPrem,
        CMCommDisc,
        DestLoad,
        AssistFees,
        AgtComm,
        CMComm,
        DomRatio,
        BankRecord
    from
        [db-au-stage].dbo.etl_corpDaysPaid

end

GO
