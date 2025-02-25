USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_PolicyEMC]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[etlsp_cmdwh_PolicyEMC]
as

SET NOCOUNT ON

--Policy EMC

if object_id('[db-au-cmdwh].dbo.PolicyEMC') is null
begin
  create table [db-au-cmdwh].dbo.PolicyEMC
  (
        CountryKey varchar(2) NOT NULL,
        PolicyEMCID int NOT NULL,
        PolicyEMCType varchar(20) NULL,            --Self-Assessed or Assessed
        CustomerID int NULL,
        AgencyCode varchar(7) NULL,
        PolicyNo int NOT NULL,
        ProductCode varchar(4) NULL,
        ClientID varchar(35) NULL,
        EMCPremiumAmount money NULL
  )
  if exists(select name from sys.indexes where name = 'idx_PolicyEMC_CountryKey')
    drop index idx_PolicyEMC_CountryKey on PolicyEMC.CountryKey

  if exists(select name from sys.indexes where name = 'idx_PolicyEMC_CustomerID')
    drop index idx_PolicyEMC_CustomerID on PolicyEMC.CustomerID

  if exists(select name from sys.indexes where name = 'idx_PolicyEMC_AgencyCode')
    drop index idx_PolicyEMC_AgencyCode on PolicyEMC.AgencyCode

  if exists(select name from sys.indexes where name = 'idx_PolicyEMC_PolicyNo')
    drop index idx_PolicyEMC_PolicyNo on PolicyEMC.PolicyNo

  if exists(select name from sys.indexes where name = 'idx_PolicyEMC_ClientID')
    drop index idx_PolicyEMC_ClientID on PolicyEMC.ClientID

  create clustered index idx_PolicyEMC_PolicyNo on [db-au-cmdwh].dbo.PolicyEMC(PolicyNo)
  create index idx_PolicyEMC_CountryKey on [db-au-cmdwh].dbo.PolicyEMC(CountryKey)
  create index idx_PolicyEMC_CustomerID on [db-au-cmdwh].dbo.PolicyEMC(CustomerID)
  create index idx_PolicyEMC_AgencyCode on [db-au-cmdwh].dbo.PolicyEMC(AgencyCode)
  create index idx_PolicyEMC_ClientID on [db-au-cmdwh].dbo.PolicyEMC(ClientID)

end
else truncate table [db-au-cmdwh].dbo.PolicyEMC



insert into [db-au-cmdwh].dbo.PolicyEMC with (tablock)
(
    CountryKey,
    PolicyEMCID,
    PolicyEMCType,
    CustomerID,
    AgencyCode,
    PolicyNo,
    ProductCode,
    ClientID,
    EMCPremiumAmount
)
select
    'AU' as CountryKey,
    PPCD_ID as PolicyEMCID,
    'Assessed' as PolicyEMCType,
    PPMULTID as CustomerID,
    PPALPHA as AgencyCode,
    PPPOLYN as PolicyNo,
    PPPOLTP as ProductCode,
    convert(varchar(35),PPDES) as ClientID,
    PPCTOT as EMCPremiumAmount
from
    [db-au-stage].dbo.trips_PPCD_au

union all

select
    'AU' as CountryKey,
    PPCD2_ID as PolicyEMCID,
    'Self-Assessed' as PolicyEMCType,
    PPMULTID as CustomerID,
    PPALPHA as AgencyCode,
    PPPOLYN as PolicyNo,
    PPPOLTP as ProductCode,
    convert(varchar(35),PPDES) as ClientID,
    PPCTOT as EMCPremiumAmount
from
    [db-au-stage].dbo.trips_PPCD2_au

union all

select
    'NZ' as CountryKey,
    PPCD_ID as PolicyEMCID,
    'Assessed' as PolicyEMCType,
    PPMULTID as CustomerID,
    PPALPHA as AgencyCode,
    PPPOLYN as PolicyNo,
    PPPOLTP as ProductCode,
    convert(varchar(35),PPDES) as ClientID,
    PPCTOT as EMCPremiumAmount
from
    [db-au-stage].dbo.trips_PPCD_nz

union all

select
    'NZ' as CountryKey,
    PPCD2_ID as PolicyEMCID,
    'Self-Assessed' as PolicyEMCType,
    PPMULTID as CustomerID,
    PPALPHA as AgencyCode,
    PPPOLYN as PolicyNo,
    PPPOLTP as ProductCode,
    convert(varchar(35),PPDES) as ClientID,
    PPCTOT as EMCPremiumAmount
from
    [db-au-stage].dbo.trips_PPCD2_nz

union all

select
    'UK' as CountryKey,
    PPCD_ID as PolicyEMCID,
    'Assessed' as PolicyEMCType,
    PPMULTID as CustomerID,
    PPALPHA as AgencyCode,
    PPPOLYN as PolicyNo,
    PPPOLTP as ProductCode,
    convert(varchar(35),PPDES) as ClientID,
    PPCTOT as EMCPremiumAmount
from
    [db-au-stage].dbo.trips_PPCD_uk

union all

select
    'UK' as CountryKey,
    PPCD2_ID as PolicyEMCID,
    'Self-Assessed' as PolicyEMCType,
    PPMULTID as CustomerID,
    PPALPHA as AgencyCode,
    PPPOLYN as PolicyNo,
    PPPOLTP as ProductCode,
    convert(varchar(35),PPDES) as ClientID,
    PPCTOT as EMCPremiumAmount
from
    [db-au-stage].dbo.trips_PPCD2_uk




--EMC Approval
if object_id('[db-au-cmdwh].dbo.EMCApproval') is null
begin

  create table [db-au-cmdwh].dbo.EMCApproval
  (
    CountryKey varchar(2) not null,
    EMCApprovalID int not null,
    PolicyEMCID int not null,
    Condition varchar(50) null,
    StatusCode varchar(10) null
  )

  if exists(select name from sys.indexes where name = 'idx_EMCApproval_CountryKey')
    drop index idx_EMCApproval_CountryKey on EMCApproval

  if exists(select name from sys.indexes where name = 'idx_EMCApproval_PolicyEMCID')
    drop index idx_EMCApproval_PolicyEMCID on EMCApproval

  create clustered index idx_EMCApproval_PolicyEMCID on [db-au-cmdwh].dbo.EMCApproval(PolicyEMCID)
  create index idx_EMCApproval_CountryKey on [db-au-cmdwh].dbo.EMCApproval(CountryKey)

end
else
  truncate table [db-au-cmdwh].dbo.EMCApproval


insert into [db-au-cmdwh].dbo.EMCApproval
(
  CountryKey,
  EMCApprovalID,
  PolicyEMCID,
  Condition,
  StatusCode
)
select
  'AU',
  ID,
  ClientID,
  Condition,
  DeniedAccepted
from trips_tblEMCApproval_au

union all

select
  'NZ',
  [Counter],
  ClientID,
  Condition,
  DeniedAccepted
from trips_tblEMCApproval_nz


GO
