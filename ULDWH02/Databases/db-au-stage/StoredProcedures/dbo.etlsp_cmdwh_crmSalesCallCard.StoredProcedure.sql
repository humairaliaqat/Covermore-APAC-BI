USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_crmSalesCallCard]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_crmSalesCallCard]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.crmSalesCallCard') is null
begin
    create TABLE [db-au-cmdwh].dbo.crmSalesCallCard
    (
        CountryKey varchar(2) NOT NULL,
        SalesCallCardID numeric(18,0) NOT NULL,
        AgencyCode varchar(7) NULL,
        StocksChecked varchar(50) NULL,
        Duration int NULL,
        CallDate datetime NULL,
        CallTime datetime NULL,
        UserDate datetime NULL
    )
    if exists(select name from sys.indexes where name = 'idx_crmSalesCallCard_CountryKey')
        drop index idx_crmSalesCallCard_CountryKey on crmSalesCallCard.CountryKey

    if exists(select name from sys.indexes where name = 'idx_crmSalesCallCard_SalesCallCardID')
        drop index idx_crmSalesCallCard_SalesCallCardID on crmSalesCallCard.SalesCallCardID

    create index idx_crmSalesCallCard_CountryKey on [db-au-cmdwh].dbo.crmSalesCallCard(CountryKey)
    create index idx_crmSalesCallCard_SalesCallCardID on [db-au-cmdwh].dbo.crmSalesCallCard(SalesCallCardID)
end
else truncate table [db-au-cmdwh].dbo.crmSalesCallCard




insert into [db-au-cmdwh].dbo.crmSalesCallCard with (tablock)
(
        CountryKey,
        SalesCallCardID,
        AgencyCode,
        StocksChecked,
        Duration,
        CallDate,
        CallTime,
        UserDate
)
select
        'AU' as CountryKey,
        SalesCallCardID,
        CLALPHA as AgencyCode,
        StocksChecked,
        Duration,
        CallDate,
        CallTime,
        UserDate
from
    [db-au-stage].dbo.trips_SalesCallCard_au

union all

select
        'NZ' as CountryKey,
        SalesCallCardID,
        CLALPHA as AgencyCode,
        StocksChecked,
        Duration,
        CallDate,
        CallTime,
        UserDate
from
    [db-au-stage].dbo.trips_SalesCallCard_nz

union all

select
        'UK' as CountryKey,
        SalesCallCardID,
        CLALPHA as AgencyCode,
        StocksChecked,
        Duration,
        CallDate,
        CallTime,
        UserDate
from
    [db-au-stage].dbo.trips_SalesCallCard_uk

union all

select
        'MY' as CountryKey,
        SalesCallCardID,
        CLALPHA as AgencyCode,
        StocksChecked,
        Duration,
        CallDate,
        CallTime,
        UserDate
from
    [db-au-stage].dbo.trips_SalesCallCard_my

union all

select
        'SG' as CountryKey,
        SalesCallCardID,
        CLALPHA as AgencyCode,
        StocksChecked,
        Duration,
        CallDate,
        CallTime,
        UserDate
from
    [db-au-stage].dbo.trips_SalesCallCard_sg

GO
