USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[vcorpQuotes]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vcorpQuotes]
as

select *
from
  [db-au-cmdwh].dbo.corpQuotes
where
  PolicyNo is not null	

GO
