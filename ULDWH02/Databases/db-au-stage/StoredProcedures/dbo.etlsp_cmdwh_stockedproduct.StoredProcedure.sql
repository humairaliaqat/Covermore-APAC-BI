USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_stockedproduct]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_stockedproduct]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.StockedProduct') is null
begin
    create table [db-au-cmdwh].dbo.StockedProduct
    (
        CountryKey varchar(2) NOT NULL,
        AgencyKey varchar(10) NULL,
        ID int NULL,
        AgencyCode varchar(7) NULL,
        AgeLoadingID int NULL,
        Comm float NULL,
        Loading float NULL,
        AdminFee money NULL,
        MaxAdminFee money NULL,
        Available bit NULL,
        CommissionTierID varchar(25) NULL,
        VolumePercentage float NULL,
        EMCLoading float NULL,
        EMCComm float NULL,
        AddonLoading float NULL,
        AddonComm float NULL,
        CLSCode smallint NULL,
        Product varchar(3) NULL
    )
    if exists(select name from sys.indexes where name = 'idx_StockedProduct_CountryKey')
        drop index idx_StockedProduct_CountryKey on StockedProduct.CountryKey

    if exists(select name from sys.indexes where name = 'idx_StockedProduct_AgencyKey')
        drop index idx_StockedProduct_AgencyKey on StockedProduct.AgencyKey

    if exists(select name from sys.indexes where name = 'idx_StockedProduct_ID')
        drop index idx_StockedProduct_ID on StockedProduct.ID

    if exists(select name from sys.indexes where name = 'idx_StockedProduct_CommissionTierID')
        drop index idx_StockedProduct_CommissionTierID on StockedProduct.CommissionTierID

    create index idx_StockedProduct_CountryKey on [db-au-cmdwh].dbo.StockedProduct(CountryKey)
    create index idx_StockedProduct_AgencyKey on [db-au-cmdwh].dbo.StockedProduct(AgencyKey)
    create index idx_StockedProduct_ID on [db-au-cmdwh].dbo.StockedProduct(ID)
    create index idx_StockedProduct_CommissionTierID on [db-au-cmdwh].dbo.StockedProduct(CommissionTierID)
end
else truncate table [db-au-cmdwh].dbo.StockedProduct



insert into [db-au-cmdwh].dbo.StockedProduct with (tablock)
(
        CountryKey,
        AgencyKey,
        ID,
        AgencyCode,
        AgeLoadingID,
        Comm,
        Loading,
        AdminFee,
        MaxAdminFee,
        Available,
        CommissionTierID,
        VolumePercentage,
        EMCLoading,
        EMCComm,
        AddonLoading,
        AddonComm,
        CLSCode,
        Product
)
select
  'AU' as CountryKey,
  'AU-' + ltrim(rtrim(left(c.CLALPHA,7))) as AgencyKey,
  convert(int,c.ID) as ID,
  convert(varchar(7),c.CLALPHA) as AgencyCode,
  convert(int,c.AgeLoadingID) as AgeLoadingID,
  convert(float,c.Comm) as Comm,
  convert(float,c.Loading) as Loading,
  convert(money,c.AdminFee) as AdminFee,
  convert(money,c.MaxAdminFee) as MaxAdminFee,
  convert(bit,c.Available) as Available,
  left(c.CommissionTierID,25) as CommissionTierID,
  convert(float,c.VolumePercentage) as VolumePercentage,
  convert(float,null) as EMCLoading,
  convert(float,null) as EMCComm,
  convert(float,null) as AddonLoading,
  convert(float,null) as AddonComm,
  convert(smallint,null) as CLSCode,
  convert(varchar(3),null) as Product
from
  [db-au-stage].dbo.trips_clstkprods_au c

union all

select
  'NZ' as CountryKey,
  'NZ-' + ltrim(rtrim(left(c.CLALPHA,7))) as AgencyKey,
  convert(int,c.ID) as ID,
  convert(varchar(7),c.CLALPHA) as AgencyCode,
  convert(int,c.AgeLoadingID) as AgeLoadingID,
  convert(float,c.Comm) as Comm,
  convert(float,c.Loading) as Loading,
  convert(money,null) as AdminFee,
  convert(money,null) as MaxAdminFee,
  convert(bit,null) as Available,
  convert(varchar(25),null) as CommissionTierID,
  convert(float,null) as VolumePercentage,
  convert(float,null) as EMCLoading,
  convert(float,null) as EMCComm,
  convert(float,null) as AddonLoading,
  convert(float,null) as AddonComm,
  convert(smallint,null) as CLSCode,
  convert(varchar(3),null) as Product
from
  [db-au-stage].dbo.trips_clstkprods_nz c

union all


select
  'UK' as CountryKey,
  'UK-' + ltrim(rtrim(left(c.CLALPHA,7))) as AgencyKey,
  convert(int,c.ID) as ID,
  convert(varchar(7),c.CLALPHA) as AgencyCode,
  convert(int,null) as AgeLoadingID,
  convert(float,c.Comm) as Comm,
  convert(float,c.Loading) as Loading,
  convert(money,null) as AdminFee,
  convert(money,null) as MaxAdminFee,
  convert(bit,null) as Available,
  convert(varchar(25),null) as CommissionTierID,
  convert(float,null) as VolumePercentage,
  convert(float,null) as EMCLoading,
  convert(float,null) as EMCComm,
  convert(float,null) as AddonLoading,
  convert(float,null) as AddonComm,
  convert(smallint,null) as CLSCode,
  convert(varchar(3),null) as Product
from
  [db-au-stage].dbo.trips_clstkprods_uk c


GO
