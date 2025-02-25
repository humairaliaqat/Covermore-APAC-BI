USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpDestination_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_corpDestination_rollup]
as

SET NOCOUNT ON

/*************************************************************/
--combine destinations from AU, NZ, AU into one table
/*************************************************************/

if object_id('[db-au-stage].dbo.etl_corpDestination') is not null drop table [db-au-stage].dbo.etl_corpDestination

select
  'AU' as CountryKey,
  left('AU-' + cast(d.DestID as varchar),10) as DestinationKey,
  left('AU-' + cast(d.QtID as varchar),10) as QuoteKey,
  d.DestID as DestinationID,
  d.QtID as QuoteID,
  d.DaysPaidID,
  d.CreatedDt as CreateDate,
  d.PropBal,
  d.DestTypeID as DestinationTypeID,
  (select top 1 DestDesc from [db-au-stage].dbo.corp_tblDestTypes_au where DestTypeID = d.DestTypeID) as DestinationDesc,
  (select top 1 DestIntDom from [db-au-stage].dbo.corp_tblDestTypes_au where DestTypeID = d.DestTypeID) as DestinationType,
  (select top 1 DestDailyRt from [db-au-stage].dbo.corp_tblDestTypes_au where DestTypeID = d.DestTypeID) as DestinationDailyRate,
  d.NoJourns,
  d.NoDays,
  d.TotDays,
  d.DaysLoad
into [db-au-stage].dbo.etl_corpDestination
from
  [db-au-stage].dbo.corp_tblDests_au d

union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(d.DestID as varchar),10) as DestinationKey,
  left('NZ-' + cast(d.QtID as varchar),10) as QuoteKey,
  d.DestID as DestinationID,
  d.QtID as QuoteID,
  d.DaysPaidID,
  d.CreatedDt as CreateDate,
  d.PropBal,
  d.DestTypeID as DestinationTypeID,
  (select top 1 DestDesc from [db-au-stage].dbo.corp_tblDestTypes_nz where DestTypeID = d.DestTypeID) as DestinationDesc,
  (select top 1 DestIntDom from [db-au-stage].dbo.corp_tblDestTypes_nz where DestTypeID = d.DestTypeID) as DestinationType,
  (select top 1 DestDailyRt from [db-au-stage].dbo.corp_tblDestTypes_nz where DestTypeID = d.DestTypeID) as DestinationDailyRate,
  d.NoJourns,
  d.NoDays,
  d.TotDays,
  d.DaysLoad
from
  [db-au-stage].dbo.corp_tblDests_nz d

union all

select
  'UK' as CountryKey,
  left('UK-' + cast(d.DestID as varchar),10) as DestinationKey,
  left('UK-' + cast(d.QtID as varchar),10) as QuoteKey,
  d.DestID as DestinationID,
  d.QtID as QuoteID,
  d.DaysPaidID,
  d.CreatedDt as CreateDate,
  d.PropBal,
  d.DestTypeID as DestinationTypeID,
  (select top 1 DestDesc from [db-au-stage].dbo.corp_tblDestTypes_uk where DestTypeID = d.DestTypeID) as DestinationDesc,
  (select top 1 DestIntDom from [db-au-stage].dbo.corp_tblDestTypes_uk where DestTypeID = d.DestTypeID) as DestinationType,
  (select top 1 DestDailyRt from [db-au-stage].dbo.corp_tblDestTypes_uk where DestTypeID = d.DestTypeID) as DestinationDailyRate,
  d.NoJourns,
  d.NoDays,
  d.TotDays,
  d.DaysLoad
from
  [db-au-stage].dbo.corp_tblDests_uk d


if object_id('[db-au-cmdwh].dbo.corpDestination') is null
begin
    create TABLE [db-au-cmdwh].dbo.corpDestination
    (
        CountryKey varchar(2) NOT NULL,
        DestinationKey varchar(10) NULL,
        QuoteKey varchar(10) NULL,
        DestinationID int NOT NULL,
        QuoteID int NULL,
        DaysPaidID int NULL,
        CreateDate datetime NULL,
        PropBal char(1) NULL,
        DestinationTypeID smallint NULL,
        DestinationDesc varchar(150) NULL,
        DestinationType varchar(50) NULL,
        NoJourns smallint NULL,
        NoDays smallint NULL,
        TotDays int NULL,
        DaysLoad money NULL
    )
    if exists(select name from sys.indexes where name = 'idx_corpDestination_CountryKey')
    drop index idx_corpDestination_CountryKey on corpDestination.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpDestination_DestinationKey')
    drop index idx_corpDestination_DestinationKey on corpDestination.DestinationKey

    if exists(select name from sys.indexes where name = 'idx_corpDestination_QuoteKey')
    drop index idx_corpDestination_QuoteKey on corpDestination.QuoteKey

    create index idx_corpDestination_CountryKey on [db-au-cmdwh].dbo.corpDestination(CountryKey)
    create index idx_corpDestination_TaxKey on [db-au-cmdwh].dbo.corpDestination(DestinationKey)
    create index idx_corpDestination_QuoteKey on [db-au-cmdwh].dbo.corpDestination(QuoteKey)
end
else
  truncate table [db-au-cmdwh].dbo.corpDestination




/*************************************************************/
-- Transfer data from [db-au-stage].dbo.etl_corpDestination to [db-au-cmdwh].dbo.corpDestination
/*************************************************************/

insert into [db-au-cmdwh].dbo.corpDestination with (tablock)
(
        CountryKey,
        DestinationKey,
        QuoteKey,
        DestinationID,
        QuoteID,
        DaysPaidID,
        CreateDate,
        PropBal,
        DestinationTypeID,
        DestinationDesc,
        DestinationType,
        NoJourns,
        NoDays,
        TotDays,
        DaysLoad
)
select
        CountryKey,
        DestinationKey,
        QuoteKey,
        DestinationID,
        QuoteID,
        DaysPaidID,
        CreateDate,
        PropBal,
        DestinationTypeID,
        DestinationDesc,
        DestinationType,
        NoJourns,
        NoDays,
        TotDays,
        DaysLoad
from [db-au-stage].dbo.etl_corpDestination


GO
