USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[tbl_cn_BI]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_cn_BI](
	[PolicyID] [varchar](10) NULL,
	[PolicyNumber] [varchar](20) NULL,
	[CreditNoteNumber] [varchar](20) NULL,
	[New_Issued_Policy_Number] [varchar](20) NULL,
	[Active_Credit_Note] [varchar](20) NULL,
	[Redeemed_Credit_Note_Policy] [varchar](20) NULL,
	[Redeemed_Credit_Note] [varchar](20) NULL
) ON [PRIMARY]
GO
