USE [db-au-stage]
GO
/****** Object:  View [dbo].[vSYSSourceColumns]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   view [dbo].[vSYSSourceColumns] as

select 'DEVSQL24.AUST.DEV.LOCAL' SERVER, getdate() TIMESTAMP, *
from
    [DEVSQL24.AUST.DEV.LOCAL].[AU_DocGen].INFORMATION_SCHEMA.COLUMNS

union all

select 'DEVSQL24.AUST.DEV.LOCAL' SERVER, getdate() TIMESTAMP, *
from
    [DEVSQL24.AUST.DEV.LOCAL].[AU_NSurvey].INFORMATION_SCHEMA.COLUMNS

union all

select 'DEVSQL24.AUST.DEV.LOCAL' SERVER, getdate() TIMESTAMP, *
from
    [DEVSQL24.AUST.DEV.LOCAL].[AU_PenguinJob].INFORMATION_SCHEMA.COLUMNS

union all

select 'DEVSQL24.AUST.DEV.LOCAL' SERVER, getdate() TIMESTAMP, *
from
    [DEVSQL24.AUST.DEV.LOCAL].[AU_PenguinSharp_Active].INFORMATION_SCHEMA.COLUMNS

union all

select 'DEVSQL24.AUST.DEV.LOCAL' SERVER, getdate() TIMESTAMP, *
from
    [DEVSQL24.AUST.DEV.LOCAL].[AU_PenguinSharp_Logs].INFORMATION_SCHEMA.COLUMNS

union all

select 'DEVSQL24.AUST.DEV.LOCAL' SERVER, getdate() TIMESTAMP, *
from
    [DEVSQL24.AUST.DEV.LOCAL].[AU_TIP_PenguinSharp_Active].INFORMATION_SCHEMA.COLUMNS

union all

select 'DEVSQL24.AUST.DEV.LOCAL' SERVER, getdate() TIMESTAMP, *
from
    [DEVSQL24.AUST.DEV.LOCAL].[Carebase].INFORMATION_SCHEMA.COLUMNS

union all

select 'DEVSQL24.AUST.DEV.LOCAL' SERVER, getdate() TIMESTAMP, *
from
    [DEVSQL24.AUST.DEV.LOCAL].[Claims].INFORMATION_SCHEMA.COLUMNS

union all

select 'DEVSQL24.AUST.DEV.LOCAL' SERVER, getdate() TIMESTAMP, *
from
    [DEVSQL24.AUST.DEV.LOCAL].[Corporate].INFORMATION_SCHEMA.COLUMNS

union all

select 'DEVSQL24.AUST.DEV.LOCAL' SERVER, getdate() TIMESTAMP, *
from
    [DEVSQL24.AUST.DEV.LOCAL].[EMC].INFORMATION_SCHEMA.COLUMNS

union all

select 'db-au-penguinsharp.aust.covermore.com.au' SERVER, getdate() TIMESTAMP, *
from
    [db-au-penguinsharp.aust.covermore.com.au].[AU_DocGen].INFORMATION_SCHEMA.COLUMNS

union all

select 'db-au-penguinsharp.aust.covermore.com.au' SERVER, getdate() TIMESTAMP, *
from
    [db-au-penguinsharp.aust.covermore.com.au].[AU_NSurvey].INFORMATION_SCHEMA.COLUMNS

union all

select 'db-au-penguinsharp.aust.covermore.com.au' SERVER, getdate() TIMESTAMP, *
from
    [db-au-penguinsharp.aust.covermore.com.au].[AU_PenguinJob].INFORMATION_SCHEMA.COLUMNS

union all

select 'db-au-penguinsharp.aust.covermore.com.au' SERVER, getdate() TIMESTAMP, *
from
    [db-au-penguinsharp.aust.covermore.com.au].[AU_PenguinSharp_Active].INFORMATION_SCHEMA.COLUMNS

union all

select 'db-au-penguinsharp.aust.covermore.com.au' SERVER, getdate() TIMESTAMP, *
from
    [db-au-penguinsharp.aust.covermore.com.au].[AU_PenguinSharp_Logs].INFORMATION_SCHEMA.COLUMNS

union all

select 'db-au-penguinsharp.aust.covermore.com.au' SERVER, getdate() TIMESTAMP, *
from
    [db-au-penguinsharp.aust.covermore.com.au].[AU_TIP_PenguinSharp_Active].INFORMATION_SCHEMA.COLUMNS

union all

select 'db-au-penguinsharp.aust.covermore.com.au' SERVER, getdate() TIMESTAMP, *
from
    [db-au-penguinsharp.aust.covermore.com.au].[Carebase].INFORMATION_SCHEMA.COLUMNS

union all

select 'db-au-penguinsharp.aust.covermore.com.au' SERVER, getdate() TIMESTAMP, *
from
    [db-au-penguinsharp.aust.covermore.com.au].[Claims].INFORMATION_SCHEMA.COLUMNS

union all

select 'db-au-penguinsharp.aust.covermore.com.au' SERVER, getdate() TIMESTAMP, *
from
    [db-au-penguinsharp.aust.covermore.com.au].[Corporate].INFORMATION_SCHEMA.COLUMNS

union all

select 'db-au-penguinsharp.aust.covermore.com.au' SERVER, getdate() TIMESTAMP, *
from
    [db-au-penguinsharp.aust.covermore.com.au].[EMC].INFORMATION_SCHEMA.COLUMNS
GO
