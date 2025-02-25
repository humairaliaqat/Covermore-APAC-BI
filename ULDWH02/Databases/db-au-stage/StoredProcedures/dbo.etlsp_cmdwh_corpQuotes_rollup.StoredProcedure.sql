USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpQuotes_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[etlsp_cmdwh_corpQuotes_rollup]
as

SET NOCOUNT ON


/*************************************************************/
--combine quotes from AU, NZ, AU into one table
/*************************************************************/

if object_id('[db-au-stage].dbo.etl_corpQuotes') is not null drop table [db-au-stage].dbo.etl_corpQuotes

select
  'AU' as CountryKey,
  left('AU-' + cast(q.Alpha as varchar) + '-' + cast(q.PolNo as varchar),41) as PolicyKey,
  left('AU-' + ltrim(rtrim(q.Alpha)),10) as AgencyKey,
  left('AU-' + cast(q.compID as varchar),10) as CompanyKey,
  left('AU-' + cast(q.QtID as varchar),10) as QuoteKey,
  left('AU-' + cast(q.PolNo as varchar),13) as CountryPolicyKey,
  q.QtID as QuoteID,
  q.QtDt as QuoteDate,
  q.Alpha as AgencyCode,
  q.CompID as CompanyID,
  q.NewRen as QuoteType,
  q.ConvToPol as isPolicy,
  q.IssueDt as IssuedDate,
  q.PolNo as PolicyNo,
  q.PolStDt as PolicyStartDate,
  q.PolExpDt as PolicyExpiryDate,
  q.Excess as Excess,
  q.PrevClaim as hasPreviousClaim,
  q.InsCanxd as hasCANX,
  q.QtRefused as hasRefused,
  (select top 1 Reason from [db-au-stage].dbo.corp_tblQtRefusalTypes_au where RefusalTypeID = q.RefusalTypeID) as RefusalDesc,
  (select top 1 PolCANXDesc from [db-au-stage].dbo.corp_tblPolCANXReasons_au where PolCANXReasonID = q.PolCANXReasonID) as CANXReasonDesc,
  q.PrevPOl as PreviousPolicyNo,
  q.BusDevMgrID as BDMID,
  q.DirSalesExecID as DirectSalesExecutiveID,
  q.LeadTypeID as LeadTypeID,
  (select top 1 LeadTypeDesc from [db-au-stage].dbo.corp_tblLeadTypes_au where LeadTypeID = q.LeadTypeID) as LeadTypeDesc,
  q.Op as Operator,
  q.GroupPol as isGroupPolicy,
  q.FreeDays
into [db-au-stage].dbo.etl_corpQuotes
from
    corp_tblQuotes_au q

union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(q.Alpha as varchar) + '-' + cast(q.PolNo as varchar),41) as PolicyKey,
  left('NZ-' + ltrim(rtrim(q.Alpha)),10) as AgencyKey,
  left('NZ-' + cast(q.compID as varchar),10) as CompanyKey,
  left('NZ-' + cast(q.QtID as varchar),10) as QuoteKey,
  left('NZ-' + cast(q.PolNo as varchar),13) as CountryPolicyKey,
  q.QtID as QuoteID,
  q.QtDt as QuoteDate,
  q.Alpha as AgencyCode,
  q.CompID as CompanyID,
  q.NewRen as QuoteType,
  q.ConvToPol as isPolicy,
  q.IssueDt as IssuedDate,
  q.PolNo as PolicyNo,
  q.PolStDt as PolicyStartDate,
  q.PolExpDt as PolicyExpiryDate,
  q.Excess as Excess,
  q.PrevClaim as hasPreviousClaim,
  q.InsCanxd as hasCANX,
  q.QtRefused as hasRefused,
  (select top 1 Reason from [db-au-stage].dbo.corp_tblQtRefusalTypes_nz where RefusalTypeID = q.RefusalTypeID) as RefusalDesc,
  (select top 1 PolCANXDesc from [db-au-stage].dbo.corp_tblPolCANXReasons_nz where PolCANXReasonID = q.PolCANXReasonID) as CANXReasonDesc,
  q.PrevPOl as PreviousPolicyNo,
  q.BusDevMgrID as BDMID,
  q.DirSalesExecID as DirectSalesExecutiveID,
  q.LeadTypeID as LeadTypeID,
  (select top 1 LeadTypeDesc from [db-au-stage].dbo.corp_tblLeadTypes_nz where LeadTypeID = q.LeadTypeID) as LeadTypeDesc,
  q.Op as Operator,
  q.GroupPol as isGroupPolicy,
  null as FreeDays
from
    corp_tblQuotes_nz q

union all

select
  'UK' as CountryKey,
  left('UK-' + cast(q.Alpha as varchar) + '-' + cast(q.PolNo as varchar),41) as PolicyKey,
  left('UK-' + ltrim(rtrim(q.Alpha)),10) as AgencyKey,
  left('UK-' + cast(q.compID as varchar),10) as CompanyKey,
  left('UK-' + cast(q.QtID as varchar),10) as QuoteKey,
  left('UK-' + cast(q.PolNo as varchar),13) as CountryPolicyKey,
  q.QtID as QuoteID,
  q.QtDt as QuoteDate,
  q.Alpha as AgencyCode,
  q.CompID as CompanyID,
  q.NewRen as QuoteType,
  q.ConvToPol as isPolicy,
  q.IssueDt as IssuedDate,
  q.PolNo as PolicyNo,
  q.PolStDt as PolicyStartDate,
  q.PolExpDt as PolicyExpiryDate,
  q.Excess as Excess,
  q.PrevClaim as hasPreviousClaim,
  q.InsCanxd as hasCANX,
  q.QtRefused as hasRefused,
  (select top 1 Reason from [db-au-stage].dbo.corp_tblQtRefusalTypes_uk where RefusalTypeID = q.RefusalTypeID) as RefusalDesc,
  (select top 1 PolCANXDesc from [db-au-stage].dbo.corp_tblPolCANXReasons_uk where PolCANXReasonID = q.PolCANXReasonID) as CANXReasonDesc,
  q.PrevPOl as PreviousPolicyNo,
  q.BusDevMgrID as BDMID,
  q.DirSalesExecID as DirectSalesExecutiveID,
  q.LeadTypeID as LeadTypeID,
  (select top 1 LeadTypeDesc from [db-au-stage].dbo.corp_tblLeadTypes_uk where LeadTypeID = q.LeadTypeID) as LeadTypeDesc,
  q.Op as Operator,
  q.GroupPol as isGroupPolicy,
  null as FreeDays
from
    corp_tblQuotes_uk q



if object_id('[db-au-cmdwh].dbo.corpQuotes') is null
begin
  create table [db-au-cmdwh].dbo.corpQuotes
  (
    BIRowID bigint not null identity(1,1),
    CountryKey varchar(2) not null,
    PolicyKey varchar(41) null,
    AgencyKey varchar(10) null,
    CompanyKey varchar(10) null,
    QuoteKey varchar(10) null,
    CountryPolicyKey varchar(13) null,
    QuoteID int not null,
    QuoteDate datetime null,
    AgencyCode varchar(7) null,
    CompanyID int null,
    QuoteType char(1) null,
    isPolicy bit null,
    IssuedDate datetime null,
    PolicyNo int null,
    PolicyStartDate datetime null,
    PolicyExpiryDate datetime null,
    Excess money null,
    hasPreviousClaim bit null,
    hasCANX bit null,
    hasRefused bit null,
    RefusalDesc varchar(50) null,
    CANXReasonDesc varchar(50) null,
    PreviousPolicyNo int null,
    BDMID int null,
    DirectSalesExecutiveID int null,
    LeadTypeID int null,
    LeadTypeDesc varchar(50) null,
    Operator varchar(10) null,
    isGroupPolicy bit null,
    FreeDays int null,
    OutletKey varchar(33)
  )

  if exists(select name from sys.indexes where name = 'idx_corpQuotes_CountryKey')
    drop index idx_corpQuotes_CountryKey on corpQuotes.CountryKey

  if exists(select name from sys.indexes where name = 'idx_corpQuotes_PolicyKey')
    drop index idx_corpQuotes_PolicyKey on corpQuotes.PolicyKey

  if exists(select name from sys.indexes where name = 'idx_corpQuotes_AgencyKey')
    drop index idx_corpQuotes_AgencyKey on corpQuotes.AgencyKey

  if exists(select name from sys.indexes where name = 'idx_corpQuotes_CompanyKey')
    drop index idx_corpQuotes_CompanyKey on corpQuotes.CompanyKey

  if exists(select name from sys.indexes where name = 'idx_corpQuotes_QuoteKey')
    drop index idx_corpQuotes_QuoteKey on corpQuotes.QuoteKey

  if exists(select name from sys.indexes where name = 'idx_corpQuotes_CountryPolicyKey')
    drop index idx_corpQuotes_CountryPolicyKey on corpQuotes.CountryPolicyKey

  if exists(select name from sys.indexes where name = 'idx_corpQuotes_PolicyNo')
    drop index idx_corpQuotes_PolicyNo on corpQuotes.PolicyNo

  if exists(select name from sys.indexes where name = 'idx_corpQuotes_QuoteID')
    drop index idx_corpQuotes_QuoteID on corpQuotes.QuoteID

  if exists(select name from sys.indexes where name = 'idx_corpQuotes_QuoteDate')
    drop index idx_corpQuotes_QuoteDate on corpQuotes.QuoteDate

  create index idx_corpQuotes_CountryKey on [db-au-cmdwh].dbo.corpQuotes(CountryKey)
  create index idx_corpQuotes_PolicyKey on [db-au-cmdwh].dbo.corpQuotes(PolicyKey)
  create index idx_corpQuotes_AgencyKey on [db-au-cmdwh].dbo.corpQuotes(AgencyKey)
  create index idx_corpQuotes_CompanyKey on [db-au-cmdwh].dbo.corpQuotes(CompanyKey)
  create index idx_corpQuotes_QuoteKey on [db-au-cmdwh].dbo.corpQuotes(QuoteKey)
  create index idx_corpQuotes_CountryPolicyKey on [db-au-cmdwh].dbo.corpQuotes(CountryPolicyKey)
  create index idx_corpQuotes_PolicyNo on [db-au-cmdwh].dbo.corpQuotes(PolicyNo)
  create index idx_corpQuotes_QuoteID on [db-au-cmdwh].dbo.corpQuotes(QuoteID)
  create index idx_corpQuotes_QuoteDate on [db-au-cmdwh].dbo.corpQuotes(QuoteDate)

end
else
begin
  truncate table [db-au-cmdwh].dbo.corpQuotes
end




/*************************************************************/
-- Transfer data from [db-au-stage].dbo.etl_corpQuotes to [db-au-cmdwh].dbo.corpQuotes
/*************************************************************/

insert into [db-au-cmdwh].dbo.corpQuotes with (tablock)
(
    CountryKey,
    PolicyKey,
    AgencyKey,
    CompanyKey,
    QuoteKey,
    CountryPolicyKey,
    QuoteID,
    QuoteDate,
    AgencyCode,
    CompanyID,
    QuoteType,
    isPolicy,
    IssuedDate,
    PolicyNo,
    PolicyStartDate,
    PolicyExpiryDate,
    Excess,
    hasPreviousClaim,
    hasCANX,
    hasRefused,
    RefusalDesc,
    CANXReasonDesc,
    PreviousPolicyNo,
    BDMID,
    DirectSalesExecutiveID,
    LeadTypeID,
    LeadTypeDesc,
    Operator,
    isGroupPolicy,
    FreeDays,
    OutletKey
)
select
    CountryKey,
    PolicyKey,
    AgencyKey,
    CompanyKey,
    QuoteKey,
    CountryPolicyKey,
    QuoteID,
    QuoteDate,
    AgencyCode,
    CompanyID,
    QuoteType,
    isPolicy,
    case
      when QuoteType = 'R' and IssuedDate is null then QuoteDate
      else IssuedDate
    end IssuedDate,
    PolicyNo,
    PolicyStartDate,
    PolicyExpiryDate,
    Excess,
    hasPreviousClaim,
    hasCANX,
    hasRefused,
    RefusalDesc,
    CANXReasonDesc,
    PreviousPolicyNo,
    BDMID,
    DirectSalesExecutiveID,
    LeadTypeID,
    LeadTypeDesc,
    Operator,
    isGroupPolicy,
    FreeDays,
    (
        select top 1 
            OutletKey
        from
            [db-au-cmdwh]..penOutlet r
        where
            r.CountryKey = t.CountryKey and
            r.AlphaCode = t.AgencyCode collate database_default
    )
from [db-au-stage].dbo.etl_corpQuotes t
GO
