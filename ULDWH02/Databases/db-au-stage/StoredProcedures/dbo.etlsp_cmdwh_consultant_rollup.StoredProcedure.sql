USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_consultant_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_consultant_rollup]
as

SET NOCOUNT ON


if OBJECT_ID('[db-au-stage].dbo.etl_consultant') is not null drop table [db-au-stage].dbo.etl_consultant

select
    'AU' as CountryKey,
    'AU-' + ltrim(rtrim(left(c.CLALPHA,7))) + '-' + ltrim(rtrim(left(isnull(c.Initials, ''), 2))) as ConsultantKey,
    c.Name as ConsultantName,
    isnull(c.Initials, '') as ConsultantInitial,
    c.UserName,
    c.[Password],
    c.CLALPHA as AgencyCode,
    c.AccessLevel,
    c.ApprovalCode,
    c.Accreditation_Number as AccreditationNo,
    c.ASICNumber as ASICNo,
    c.AgrDate as AgreementDate,
    c.Email,
    null as PayrollID,
    c.ID as ConsultantID
into [db-au-stage].dbo.etl_consultant
from
    [db-au-stage].dbo.trips_consultant_au c

union all

select
    'NZ' as CountryKey,
    'NZ-' + ltrim(rtrim(left(c.CLALPHA,7))) + '-' + ltrim(rtrim(left(isnull(c.Initials, ''), 2))) as ConsultantKey,
    c.Name as ConsultantName,
    isnull(c.Initials, '') as ConsultantInitial,
    c.UserName,
    c.[Password],
    c.CLALPHA as AgencyCode,
    c.AccessLevel,
    c.ApprovalCode,
    c.Accreditation_Number as AccreditationNo,
    c.ASICNumber as ASICNo,
    c.AgrDate as AgreementDate,
    c.Email,
    ltrim(rtrim(left(c.PAYROLLID,50))) as PayrollID,
    c.ID as ConsultantID
from
    [db-au-stage].dbo.trips_consultant_nz c

union all

select
    'UK' as CountryKey,
    'UK-' + ltrim(rtrim(left(c.CLALPHA,7))) + '-' + ltrim(rtrim(left(isnull(c.Initials, ''), 2))) as ConsultantKey,
    c.Name as ConsultantName,
    isnull(c.Initials, '') as ConsultantInitial,
    c.UserName,
    c.[Password],
    c.CLALPHA as AgencyCode,
    c.AccessLevel,
    c.ApprovalCode,
    c.Accreditation_Number as AccreditationNo,
    c.ASICNumber as ASICNo,
    c.AgrDate as AgreementDate,
    c.Email,
    ltrim(rtrim(left(c.PAYROLLID,50))) as PayrollID,
    c.ID as ConsultantID
from
    [db-au-stage].dbo.trips_consultant_uk c

union all

select
    'MY' as CountryKey,
    'MY-' + ltrim(rtrim(left(c.CLALPHA,7))) + '-' + ltrim(rtrim(left(isnull(c.Initials, ''), 2))) as ConsultantKey,
    c.Name as ConsultantName,
    isnull(c.Initials, '') as ConsultantInitial,
    c.UserName,
    c.[Password],
    c.CLALPHA as AgencyCode,
    c.AccessLevel,
    c.ApprovalCode,
    c.Accreditation_Number as AccreditationNo,
    c.ASICNumber as ASICNo,
    c.AgrDate as AgreementDate,
    c.Email,
    null as PayrollID,
    c.ID as ConsultantID
from
    [db-au-stage].dbo.trips_consultant_my c

union all

select
    'SG' as CountryKey,
    'SG-' + ltrim(rtrim(left(c.CLALPHA,7))) + '-' + ltrim(rtrim(left(isnull(c.Initials, ''), 2))) as ConsultantKey,
    c.Name as ConsultantName,
    isnull(c.Initials, '') as ConsultantInitial,
    c.UserName,
    c.[Password],
    c.CLALPHA as AgencyCode,
    c.AccessLevel,
    c.ApprovalCode,
    c.Accreditation_Number as AccreditationNo,
    c.ASICNumber as ASICNo,
    c.AgrDate as AgreementDate,
    c.Email,
    null as PayrollID,
    c.ID as ConsultantID
from
    [db-au-stage].dbo.trips_consultant_sg c

if object_id('[db-au-cmdwh].dbo.Consultant') is null
begin
  create table [db-au-cmdwh].dbo.Consultant
  (
    CountryKey varchar(2) not null,
    ConsultantKey varchar(13) not null,
    ConsultantName varchar(50) null,
    ConsultantInitial varchar(4) null,
    UserName varchar(50) null,
    [Password] varchar(50) null,
    AgencyCode varchar(7) null,
    AccessLevel int null,
    ApprovalCode varchar(50) null,
    AccreditationNo varchar(50) null,
    ASICNo int null,
    AgreementDate datetime null,
    Email varchar(100) null,
    PayrollID varchar(50) null,
    ConsultantID int null
  )
  if exists(select name from sys.indexes where name = 'idx_Consultant_CountryKey')
    drop index idx_Consultant_CountryKey on Consultant.CountryKey

  if exists(select name from sys.indexes where name = 'idx_Consultant_ConsultantKey')
    drop index idx_Consultant_ConsultantKey on Consultant.ConsultantKey

  if exists(select name from sys.indexes where name = 'idx_Consultant_ConsultantID')
    drop index idx_Consultant_ConsultantID on Consultant.ConsultantID

  create index idx_Consultant_CountryKey on [db-au-cmdwh].dbo.Consultant(CountryKey)
  create index idx_Consultant_PolicyKey on [db-au-cmdwh].dbo.Consultant(ConsultantKey)
  create index idx_Consultant_ConsultantID on [db-au-cmdwh].dbo.Consultant(ConsultantID)
end
else
  truncate table [db-au-cmdwh].dbo.Consultant



-- Transfer data from [db-au-stage].dbo.etl_consultant to [db-au-cmdwh].dbo.Consultant
insert into [db-au-cmdwh].dbo.Consultant with (tablock)
(
    CountryKey,
    ConsultantKey,
    ConsultantName,
    ConsultantInitial,
    UserName,
    [Password],
    AgencyCode,
    AccessLevel,
    ApprovalCode,
    AccreditationNo,
    ASICNo,
    AgreementDate,
    Email,
    PayrollID,
    ConsultantID
)
select * from [db-au-stage].dbo.etl_consultant



GO
