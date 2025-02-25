USE [db-au-workspace]
GO
/****** Object:  Table [ws].[ITCDAMFixes_06022024]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ws].[ITCDAMFixes_06022024](
	[claimno] [bigint] NULL,
	[claimID] [bigint] NULL,
	[ITC_DAM] [real] NULL,
	[AUD_amt] [real] NULL,
	[PaymentKey] [varchar](40) NULL,
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO
