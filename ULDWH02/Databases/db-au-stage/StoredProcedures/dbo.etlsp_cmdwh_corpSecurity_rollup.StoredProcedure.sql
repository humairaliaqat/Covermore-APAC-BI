USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpSecurity_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_corpSecurity_rollup]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.corpSecurity') is null
begin
    create table [db-au-cmdwh].dbo.corpSecurity
    (
        [CountryKey] [varchar](2) NOT NULL,
        [SecurityKey] [varchar](10) NULL,
        [SecurityID] [int] NULL,
        [Login] [varchar](15) NULL,
        [Password] [varchar](15) NULL,
        [FullName] [varchar](50) NULL,
        [SecurityLevel] [varchar](50) NULL,
        [JobDesc] [varchar](50) NULL,
        [Signature] [image] NULL,
        [isSuperAdmin] [bit] NULL
    )

    if exists(select name from sys.indexes where name = 'idx_corpSecurity_CountryKey')
    drop index idx_corpSecurity_CountryKey on corpSecurity.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpSecurity_SecurityKey')
    drop index idx_corpSecurity_SecurityKey on corpSecurity.SecurityKey

    create index idx_corpSecurity_CountryKey on [db-au-cmdwh].dbo.corpSecurity(CountryKey)
    create index idx_corpSecurity_SecurityKey on [db-au-cmdwh].dbo.corpSecurity(SecurityKey)
end
else
    truncate table [db-au-cmdwh].dbo.corpSecurity



insert into [db-au-cmdwh].dbo.corpSecurity with (tablock)
(
    [CountryKey],
    [SecurityKey],
    [SecurityID],
    [Login],
    [Password],
    [FullName],
    [SecurityLevel],
    [JobDesc],
    [Signature],
    [isSuperAdmin]
)
select
  'AU' as CountryKey,
  left('AU-' + cast(s.ID as varchar),10) as SecurityKey,
  s.ID as SecurityID,
  s.[Login] as [Login],
  s.[Password] as [Password],
  s.FullName,
  s.SecurityLevel,
  s.JobDesc,
  s.[Signature],
  s.isSuperAdmin
from
  [db-au-stage].dbo.corp_tblSecurity_au s

union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(s.ID as varchar),10) as SecurityKey,
  s.ID as SecurityID,
  s.[Login] as [Login],
  s.[Password] as [Password],
  s.FullName,
  s.SecurityLevel,
  s.JobDesc,
  s.[Signature],
  null as isSuperAdmin
from
  [db-au-stage].dbo.corp_tblSecurity_nz s

union all

select
  'UK' as CountryKey,
  left('UK-' + cast(s.ID as varchar),10) as SecurityKey,
  s.ID as SecurityID,
  s.[Login] as [Login],
  s.[Password] as [Password],
  s.FullName,
  s.SecurityLevel,
  null as JobDesc,
  null as [Signature],
  null as isSuperAdmin
from
  [db-au-stage].dbo.corp_tblSecurity_uk s


GO
