USE [db-au-workspace]
GO
/****** Object:  Table [dataset].[claim_au_incurred]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dataset].[claim_au_incurred](
	[CurrentMonthFlag] [varchar](3) NOT NULL,
	[MonthPeriod] [date] NULL,
	[Date] [smalldatetime] NOT NULL,
	[ClaimGroup] [varchar](7) NOT NULL,
	[Bucket] [varchar](10) NOT NULL,
	[benefit] [varchar](12) NOT NULL,
	[ClaimCostCY] [decimal](38, 6) NULL,
	[ClaimEstimateCY] [decimal](38, 6) NULL,
	[ClaimPaymentCY] [money] NULL,
	[ClaimCostPY] [decimal](38, 6) NULL,
	[ClaimEstimatePY] [decimal](38, 6) NULL,
	[ClaimPaymentPY] [money] NULL,
	[ClaimVolumeCY] [int] NULL,
	[ClaimVolumePY] [int] NULL
) ON [PRIMARY]
GO
