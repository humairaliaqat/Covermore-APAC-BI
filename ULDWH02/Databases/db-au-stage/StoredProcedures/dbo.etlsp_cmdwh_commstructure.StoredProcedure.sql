USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_commstructure]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_commstructure]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.usrCommStructure') is null
begin
  create table [db-au-cmdwh].dbo.usrCommStructure
  (
    [CountryKey] [varchar](2) NOT NULL,
    [AgencyKey] [varchar](10) NOT NULL,
    [AgencyCode] [varchar](7) NULL,
    [ProductCode] [varchar](10) NULL,
    [PlanCode] [varchar](10) NULL,
    [Commission] [float] NULL,
    [Loading] [float] NULL,
    [AdminFee] [money] NULL,
    [MaxAdminFee] [money] NULL,
    [AvailableFlag] [bit] NULL,
    [CommissionTierID] [varchar](25) NULL,
    [VolumePercentage] [float] NULL
  )

  if exists(select name from sys.indexes where name = 'idx_usrCommStructure_CountryKey')
    drop index idx_usrCommStructure_CountryKey on usrCommStructure.CountryKey

  if exists(select name from sys.indexes where name = 'idx_usrCommStructure_AgencyKey')
    drop index idx_usrCommStructure_AgencyKey on usrCommStructure.AgencyKey

  if exists(select name from sys.indexes where name = 'idx_usrCommStructure_AgencyCode')
    drop index idx_usrCommStructure_AgencyCode on usrCommStructure.AgencyCode

  if exists(select name from sys.indexes where name = 'idx_usrCommStructure_ProductCode')
    drop index idx_usrCommStructure_ProductCode on usrCommStructure.ProductCode

  if exists(select name from sys.indexes where name = 'idx_usrCommStructure_PlanCode')
    drop index idx_usrCommStructure_PlanCode on usrCommStructure.PlanCode

  create index idx_usrCommStructure_CountryKey on [db-au-cmdwh].dbo.usrCommStructure(CountryKey)
  create index idx_usrCommStructure_AgencyKey on [db-au-cmdwh].dbo.usrCommStructure(AgencyKey)
  create index idx_usrCommStructure_AgencyCode on [db-au-cmdwh].dbo.usrCommStructure(AgencyCode)
  create index idx_usrCommStructure_ProductCode on [db-au-cmdwh].dbo.usrCommStructure(ProductCode)
  create index idx_usrCommStructure_PlanCode on [db-au-cmdwh].dbo.usrCommStructure(PlanCode)
end
else
  truncate table [db-au-cmdwh].dbo.usrCommStructure





insert into [db-au-cmdwh].dbo.usrCommStructure with (tablock)
(
    [CountryKey],
    [AgencyKey],
    [AgencyCode],
    [ProductCode],
    [PlanCode],
    [Commission],
    [Loading],
    [AdminFee],
    [MaxAdminFee],
    [AvailableFlag],
    [CommissionTierID],
    [VolumePercentage]
)
select distinct
  a.CountryKey,
  a.AgencyKey,
  a.AgencyCode,
  tp.ProductCodeDisplay as ProductCode,
  tp.PlanCode,
  case when isNull(c.Comm,0) = 0 then 0
       else round((((c.Comm - 1) / c.Comm) * 100),2)
  end as Commission,
  c.LOADING as Loading,
  c.ADMINFEE as AdminFee,
  c.MAXADMINFEE as MaxAdminFee,
  c.AVAILABLE as AvailableFlag,
  c.COMMISSIONTIERID as CommissionTierID,
  case when isNull(c.VolumePercentage,0) = 0 then 0
       else round((((c.VOLUMEPERCENTAGE - 1) / c.VOLUMEPERCENTAGE) * 100),2)
  end as VolumePercentage
from
  [db-au-cmdwh].dbo.Agency a
  join [db-au-cmdwh].dbo.StockedProduct c on
    a.CountryKey = c.CountryKey and
    a.AgencyCode = c.AgencyCode
  join [db-au-cmdwh].dbo.AgeLoading ta ON
    ta.CountryKey = c.CountryKey and
    ta.AGELOADINGID = c.AGELOADINGID
  join [db-au-cmdwh].dbo.ProductPlan tp ON
    tp.CountryKey = ta.CountryKey and
    tp.PlanId = ta.PlanId
where
  c.AVAILABLE = 1 and
  c.COMMISSIONTIERID is not null and
  tp.PlanID not in (31,32,33,34,231,232,233,234)




GO
