USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpMiscCode_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_corpMiscCode_rollup]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.corpMiscCode') is null
begin
    create table [db-au-cmdwh].dbo.corpMiscCode
    (
        [CountryKey] [varchar](2) NOT NULL,
        [MiscKey] [varchar](10) NULL,
        [MiscID] [int] NULL,
        [MiscCode] [varchar](50) NULL,
        [MiscDesc] [varchar](50) NULL,
        [MiscComments] [varchar](200) NULL
    )

    if exists(select name from sys.indexes where name = 'idx_corpMiscCode_CountryKey')
    drop index idx_corpMiscCode_CountryKey on corpMiscCode.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpMiscCode_MiscKey')
    drop index idx_corpMiscCode_MiscKey on corpLuggage.MiscKey

    create index idx_corpMiscCode_CountryKey on [db-au-cmdwh].dbo.corpMiscCode(CountryKey)
    create index idx_corpMiscCode_MiscKey on [db-au-cmdwh].dbo.corpMiscCode(MiscKey)

end
else
    truncate table [db-au-cmdwh].dbo.corpMiscCode



insert into [db-au-cmdwh].dbo.corpMiscCode with (tablock)
(
    [CountryKey],
    [MiscKey],
    [MiscID],
    [MiscCode],
    [MiscDesc],
    [MiscComments]
)
select
  'AU' as CountryKey,
  left('AU-' + cast(m.MiscID as varchar),10) as MiscKey,
  m.MiscID as MiscID,
  m.MiscCode as MiscCode,
  m.MiscDesc as MiscDesc,
  m.MiscComments
from
  [db-au-stage].dbo.corp_tblMiscCodes_au m

union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(m.MiscID as varchar),10) as MiscKey,
  m.MiscID as MiscID,
  m.MiscCode as MiscCode,
  m.MiscDesc as MiscDesc,
  m.MiscComments
from
  [db-au-stage].dbo.corp_tblMiscCodes_nz m


GO
