USE [db-au-star]
GO
/****** Object:  View [dbo].[dimDateRange]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[dimDateRange]
as
select 
    '{[Date].[Date].&[' + replace(convert(varchar(10), StartDate, 120), '-', '') + ']:[Date].[Date].&[' + replace(convert(varchar(10), EndDate, 120), '-', '') + ']}' MDX,
    [DateRange]
from
    [db-au-cmdwh].dbo.vdaterange
where
    [DateRange] <> '_User Defined'
GO
