USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_crmCallSubCategory]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_crmCallSubCategory]
as

SET NOCOUNT ON

if object_id('[db-au-cmdwh].dbo.crmCallSubCategory') is null
begin
    create TABLE [db-au-cmdwh].dbo.crmCallSubCategory
    (
        CountryKey varchar(2) not null,
        Department varchar(50) null,
        SubCategory varchar(100) null
    )
end
else truncate table [db-au-cmdwh].dbo.crmCallSubCategory




insert into [db-au-cmdwh].dbo.crmCallSubCategory with (tablock)
(
    CountryKey,
    Department,
    SubCategory
)
select
    'AU' as CountryKey,
    Dep as Department,
    SubCategory
from
    [db-au-stage].dbo.trips_CRMCallSubCategory_au

union all

select
    'NZ' as CountryKey,
    Dep as Department,
    SubCategory
from
    [db-au-stage].dbo.trips_CRMCallSubCategory_nz

union all

select
    'UK' as CountryKey,
    Dep as Department,
    SubCategory
from
    [db-au-stage].dbo.trips_CRMCallSubCategory_uk

union all

select
    'MY' as CountryKey,
    Dep as Department,
    SubCategory
from
    [db-au-stage].dbo.trips_CRMCallSubCategory_my

union all

select
    'SG' as CountryKey,
    Dep as Department,
    SubCategory
from
    [db-au-stage].dbo.trips_CRMCallSubCategory_sg

GO
