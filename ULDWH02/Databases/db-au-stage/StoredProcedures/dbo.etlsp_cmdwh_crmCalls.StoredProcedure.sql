USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_crmCalls]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_crmCalls]
as

SET NOCOUNT ON

if object_id('[db-au-cmdwh].dbo.crmCalls') is null
begin
    create TABLE [db-au-cmdwh].dbo.crmCalls
    (
        CountryKey varchar(2) NOT NULL,
        CRMCallsID numeric(18, 0) NOT NULL,
        AgencyCode char(7) NULL,
        Consultant varchar(50) NULL,
        Attitude numeric(18, 0) NULL,
        Category varchar(100) NULL,
        SubCategory varchar(100) NULL,
        SubCategoryDetails varchar(100) NULL,
        CallDate datetime NULL,
        CallTime datetime NULL
    )
end
else truncate table [db-au-cmdwh].dbo.crmCalls





insert into [db-au-cmdwh].dbo.crmCalls with (tablock)
(
        CountryKey,
        CRMCallsID,
        AgencyCode,
        Consultant,
        Attitude,
        Category,
        SubCategory,
        SubCategoryDetails,
        CallDate,
        CallTime
)
select
        'AU' as CountryKey,
        CRMCallsID,
        CLALPHA as AgencyCode,
        Consultant,
        Attitude,
        Category,
        SubCategory,
        SubCatDetails as SubCategoryDetails,
        CallDate,
        CallTime
from
    [db-au-stage].dbo.trips_CRMCalls_au

union all

select
        'NZ' as CountryKey,
        CRMCallsID,
        CLALPHA as AgencyCode,
        Consultant,
        Attitude,
        Category,
        SubCategory,
        SubCatDetails as SubCategoryDetails,
        CallDate,
        CallTime
from
    [db-au-stage].dbo.trips_CRMCalls_nz

union all

select
        'UK' as CountryKey,
        CRMCallsID,
        CLALPHA as AgencyCode,
        Consultant,
        Attitude,
        Category,
        SubCategory,
        SubCatDetails as SubCategoryDetails,
        CallDate,
        CallTime
from
    [db-au-stage].dbo.trips_CRMCalls_uk

union all

select
        'MY' as CountryKey,
        CRMCallsID,
        CLALPHA as AgencyCode,
        Consultant,
        Attitude,
        Category,
        SubCategory,
        SubCatDetails as SubCategoryDetails,
        CallDate,
        CallTime
from
    [db-au-stage].dbo.trips_CRMCalls_my

union all

select
        'SG' as CountryKey,
        CRMCallsID,
        CLALPHA as AgencyCode,
        Consultant,
        Attitude,
        Category,
        SubCategory,
        SubCatDetails as SubCategoryDetails,
        CallDate,
        CallTime
from
    [db-au-stage].dbo.trips_CRMCalls_sg

GO
