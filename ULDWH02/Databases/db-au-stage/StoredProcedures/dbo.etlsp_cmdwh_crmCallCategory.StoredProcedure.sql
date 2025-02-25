USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_crmCallCategory]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_crmCallCategory]
as

SET NOCOUNT ON

if object_id('[db-au-cmdwh].dbo.crmCallCategory') is null
begin
    create TABLE [db-au-cmdwh].dbo.crmCallCategory
    (
        CountryKey varchar(2) not null,
        Department varchar(50) null,
        Category varchar(250) null
    )
end
else truncate table [db-au-cmdwh].dbo.crmCallCategory





insert into [db-au-cmdwh].dbo.crmCallCategory with (tablock)
(
    CountryKey,
    Department,
    Category
)
select
    'AU' as CountryKey,
    Dep as Department,
    Category
from
    [db-au-stage].dbo.trips_CRMCallCategory_au

union all

select
    'NZ' as CountryKey,
    Dep as Department,
    Category
from
    [db-au-stage].dbo.trips_CRMCallCategory_nz

union all

select
    'UK' as CountryKey,
    Dep as Department,
    Category
from
    [db-au-stage].dbo.trips_CRMCallCategory_uk

union all

select
    'MY' as CountryKey,
    Dep as Department,
    Category
from
    [db-au-stage].dbo.trips_CRMCallCategory_my

union all

select
    'SG' as CountryKey,
    Dep as Department,
    Category
from
    [db-au-stage].dbo.trips_CRMCallCategory_sg

GO
