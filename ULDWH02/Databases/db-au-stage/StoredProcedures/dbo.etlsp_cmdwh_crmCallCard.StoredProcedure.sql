USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_crmCallCard]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_crmCallCard]
as

SET NOCOUNT ON

if object_id('[db-au-cmdwh].dbo.crmCallCard') is null
begin
    create TABLE [db-au-cmdwh].dbo.crmCallCard
    (
        CountryKey varchar(2) not null,
        CRMCallCardID numeric(18, 0) NOT NULL,
        CRMCallsID numeric(18, 0) NULL,
        SalesRepCallCardID numeric(18, 0) NULL,
        AgencyCode char(7) NULL,
        CallDate datetime NULL,
        CallTime datetime NULL,
        CallRemarks varchar(4000) NULL,
        PersonalRemarks varchar(1000) NULL,
        Rep varchar(50) NULL,
        RepType varchar(20) NULL
    )
    if exists(select name from sys.indexes where name = 'idx_crmCallCard_CountryKey')
        drop index idx_crmCallCard_CountryKey on crmCallCard.CountryKey

    if exists(select name from sys.indexes where name = 'idx_crmCallCard_CRMCallCardID')
        drop index idx_crmCallCard_CRMCallCardID on crmCallCard.CRMCallCardID

    if exists(select name from sys.indexes where name = 'idx_crmCallCard_CRMCallID')
        drop index idx_crmCallCard_CRMCallID on crmCallCard.CRMCallID

    if exists(select name from sys.indexes where name = 'idx_crmCallCard_SalesRepCallCardID')
        drop index idx_crmCallCard_SalesRepCallCardID on crmCallCard.SalesRepCallCardID

    create index idx_crmCallCard_CountryKey on [db-au-cmdwh].dbo.crmCallCard(CountryKey)
    create index idx_crmCallCard_CRMCallCardID on [db-au-cmdwh].dbo.crmCallCard(CRMCallCardID)
    create index idx_crmCallCard_CRMCallID on [db-au-cmdwh].dbo.crmCallCard(CRMCallsID)
    create index idx_crmCallCard_SalesrepCallCardID on [db-au-cmdwh].dbo.crmCallCard(SalesRepCallCardID)
end
else truncate table [db-au-cmdwh].dbo.crmCallCard



insert into [db-au-cmdwh].dbo.crmCallCard with (tablock)
(
    CountryKey,
    CRMCallCardID,
    CRMCallsID,
    SalesRepCallCardID,
    AgencyCode,
    CallDate,
    CallTime,
    CallRemarks,
    PersonalRemarks,
    Rep,
    RepType
)
select
    'AU' as CountryKey,
    CRMCallCardID,
    CRMCallsID,
    SalesRepCallCardID,
    CLALPHA as AgencyCode,
    CallDate,
    CallTime,
    CallRemarks,
    PersonalRemarks,
    Rep,
    RepType
from
    [db-au-stage].dbo.trips_CRMCallCard_au

union all

select
    'NZ' as CountryKey,
    CRMCallCardID,
    CRMCallsID,
    SalesRepCallCardID,
    CLALPHA as AgencyCode,
    CallDate,
    CallTime,
    CallRemarks,
    PersonalRemarks,
    Rep,
    RepType
from
    [db-au-stage].dbo.trips_CRMCallCard_nz

union all

select
    'UK' as CountryKey,
    CRMCallCardID,
    CRMCallsID,
    SalesRepCallCardID,
    CLALPHA as AgencyCode,
    CallDate,
    CallTime,
    CallRemarks,
    PersonalRemarks,
    Rep,
    RepType
from
    [db-au-stage].dbo.trips_CRMCallCard_uk

union all

select
    'MY' as CountryKey,
    CRMCallCardID,
    CRMCallsID,
    SalesRepCallCardID,
    CLALPHA as AgencyCode,
    CallDate,
    CallTime,
    CallRemarks,
    PersonalRemarks,
    Rep,
    RepType
from
    [db-au-stage].dbo.trips_CRMCallCard_my

union all

select
    'SG' as CountryKey,
    CRMCallCardID,
    CRMCallsID,
    SalesRepCallCardID,
    CLALPHA as AgencyCode,
    CallDate,
    CallTime,
    CallRemarks,
    PersonalRemarks,
    Rep,
    RepType
from
    [db-au-stage].dbo.trips_CRMCallCard_sg

GO
