USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_ageloading]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_ageloading]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.AgeLoading') is null
begin
    create table [db-au-cmdwh].dbo.AgeLoading
    (
        CountryKey varchar(2) NOT NULL,
        AgeLoadingID int NULL,
        PlanID int null,
        DurationID int null,
        AgeBracket varchar(10) null,
        NetRate float null,
        ClGroup varchar(10) null,
        B2BOnly varchar(1) null

    )
    if exists(select name from sys.indexes where name = 'idx_AgeLoading_CountryKey')
        drop index idx_AgeLoading_CountryKey on AgeLoading.CountryKey

    if exists(select name from sys.indexes where name = 'idx_AgeLoading_AgeLoadingID')
        drop index idx_AgeLoading_AgeLoadingID on AgeLoading.AgeLoadingID

    if exists(select name from sys.indexes where name = 'idx_AgeLoading_PlanID')
        drop index idx_AgeLoading_AgencyKey on AgeLoading.PlanID

    create index idx_AgeLoading_CountryKey on [db-au-cmdwh].dbo.AgeLoading(CountryKey)
    create index idx_AgeLoading_AgeLoadingID on [db-au-cmdwh].dbo.AgeLoading(AgeLoadingID)
    create index idx_AgeLoading_PlanID on [db-au-cmdwh].dbo.AgeLoading(PlanID)
end
else truncate table [db-au-cmdwh].dbo.AgeLoading



insert into [db-au-cmdwh].dbo.AgeLoading with (tablock)
(
    CountryKey,
    AgeLoadingID,
    PlanID,
    DurationID,
    AgeBracket,
    NetRate,
    ClGroup,
    B2BOnly
)
select
    'AU' as CountryKey,
    convert(int,a.AgeLoadingID) as AgeLoadingID,
    convert(int,a.PlanID) as PlanID,
    convert(int,null) as DurationID,
    convert(varchar(10),a.AgeBracket) as AgeBracket,
    convert(float,a.NetRate) as NetRate,
    convert(varchar(10),null) as ClGroup,
    convert(varchar(1),null) as B2BOnly
from
    [db-au-stage].dbo.trips_tblageloading_a_au a

union all

select
  'NZ' as CountryKey,
    convert(int,a.AgeLoadingID) as AgeLoadingID,
    convert(int,a.PlanID) as PlanID,
    convert(int,null) as DurationID,
    convert(varchar(10),a.AgeBracket) as AgeBracket,
    convert(float,a.NetRate) as NetRate,
    convert(varchar(10),null) as ClGroup,
    convert(varchar(1),null) as B2BOnly
from
    [db-au-stage].dbo.trips_tblageloading_nz a

union all


select
    'UK' as CountryKey,
    convert(int,null) as AgeLoadingID,
    convert(int,a.PlanID) as PlanID,
    convert(int,a.DurationID) as DurationID,
    convert(varchar(10),a.AgeBracket) as AgeBracket,
    convert(float,a.NetRate) as NetRate,
    convert(varchar(10),a.CLGroup) as ClGroup,
    convert(varchar(1),a.B2BOnly) as B2BOnly
from
  [db-au-stage].dbo.trips_tblageloading_uk a



GO
