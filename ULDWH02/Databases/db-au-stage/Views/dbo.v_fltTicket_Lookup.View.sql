USE [db-au-stage]
GO
/****** Object:  View [dbo].[v_fltTicket_Lookup]    Script Date: 24/02/2025 5:08:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_fltTicket_Lookup]
AS SELECT document_number, HashKey, BIRowID
   FROM [db-au-cmdwh].dbo.fltTicket
   Where isLatest = 'Y'
   And (local_Issue_date >= dateadd(month,-4, convert(datetime,'2017-04-01'))
   Or Refunded_date >= dateadd(month,-12, convert(datetime,'2017-04-01')))
GO
