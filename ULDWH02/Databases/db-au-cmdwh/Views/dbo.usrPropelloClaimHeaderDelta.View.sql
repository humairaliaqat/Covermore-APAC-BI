USE [db-au-cmdwh]
GO
/****** Object:  View [dbo].[usrPropelloClaimHeaderDelta]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[usrPropelloClaimHeaderDelta] as select * from [BHDWH03].[db-au-dataout].[dbo].PROPELLO_RAW_CLAIM_HEADER_DELTA
GO
