USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[tbl_Finance_CN]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Finance_CN](
	[CreditNoteNumber] [nvarchar](15) NOT NULL,
	[OriginalPolicyId] [int] NOT NULL,
	[New_Issued] [varchar](50) NULL,
	[RedeemPolicyId] [int] NULL,
	[Redeemed] [varchar](50) NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[Rnk] [bigint] NULL
) ON [PRIMARY]
GO
