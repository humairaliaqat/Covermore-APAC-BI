USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[usrPropelloClaimLine]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[usrPropelloClaimLine] as select * from [BHDWH03].[db-au-dataout].[dbo].PROPELLO_RAW_CLAIM_LINE
GO
