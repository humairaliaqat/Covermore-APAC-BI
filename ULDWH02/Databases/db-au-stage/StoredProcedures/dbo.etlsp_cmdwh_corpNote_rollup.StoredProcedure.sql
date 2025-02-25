USE [db-au-stage]
GO
/****** Object:  StoredProcedure [dbo].[etlsp_cmdwh_corpNote_rollup]    Script Date: 24/02/2025 5:08:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[etlsp_cmdwh_corpNote_rollup]
as

SET NOCOUNT ON


if object_id('[db-au-cmdwh].dbo.corpNote') is null
begin
    create table [db-au-cmdwh].dbo.corpNote
    (
        [CountryKey] [varchar](2) NOT NULL,
        [NoteKey] [varchar](10) NULL,
        [QuoteKey] [varchar](10) NULL,
        [NoteID] [int] NULL,
        [QuoteID] [int] NULL,
        [Username] [varchar](50) NULL,
        [CreateDate] [datetime] NULL,
        [Notes] [text] NULL
    )

    if exists(select name from sys.indexes where name = 'idx_corpNote_CountryKey')
    drop index idx_corpNote_CountryKey on corpNote.CountryKey

    if exists(select name from sys.indexes where name = 'idx_corpNote_NoteKey')
    drop index idx_corpNote_NoteKey on corpNote.NoteKey

    if exists(select name from sys.indexes where name = 'idx_corpNote_QuoteKey')
    drop index idx_corpNote_QuoteKey on corpNote.QuoteKey

    create index idx_corpNote_CountryKey on [db-au-cmdwh].dbo.corpNote(CountryKey)
    create index idx_corpNote_NoteKey on [db-au-cmdwh].dbo.corpNote(NoteKey)
    create index idx_corpNote_QuoteKey on [db-au-cmdwh].dbo.corpNote(QuoteKey)
end
else
    truncate table [db-au-cmdwh].dbo.corpNote



insert into [db-au-cmdwh].dbo.corpNote with (tablock)
(
    [CountryKey],
    [NoteKey],
    [QuoteKey],
    [NoteID],
    [QuoteID],
    [Username],
    [CreateDate],
    [Notes]
)
select
  'AU' as CountryKey,
  left('AU-' + cast(n.NoteID as varchar),10) as NoteKey,
  left('AU-' + cast(n.QtID as varchar),10) as QuoteKey,
  n.NoteID as NoteID,
  n.QtID as QuoteID,
  n.NoteAc as Username,
  n.NoteDate as CreateDate,
  n.Notes
from
  [db-au-stage].dbo.corp_tblNotes_au n

union all

select
  'NZ' as CountryKey,
  left('NZ-' + cast(n.NoteID as varchar),10) as NoteKey,
  left('NZ-' + cast(n.QtID as varchar),10) as QuoteKey,
  n.NoteID as NoteID,
  n.QtID as QuoteID,
  n.NoteAc as Username,
  n.NoteDate as CreateDate,
  n.Notes
from
  [db-au-stage].dbo.corp_tblNotes_nz n

union all

select
  'UK' as CountryKey,
  left('UK-' + cast(n.NoteID as varchar),10) as NoteKey,
  left('UK-' + cast(n.QtID as varchar),10) as QuoteKey,
  n.NoteID as NoteID,
  n.QtID as QuoteID,
  n.NoteAc as Username,
  n.NoteDate as CreateDate,
  n.Notes
from
  [db-au-stage].dbo.corp_tblNotes_uk n


GO
