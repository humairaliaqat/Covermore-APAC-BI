USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[comm__base_policy_mode]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[comm__base_policy_mode](
	[OutletAlphaKey] [nvarchar](50) NOT NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[OutletName] [nvarchar](50) NULL,
	[JV] [nvarchar](100) NULL,
	[GroupName] [nvarchar](50) NULL,
	[PostingDate] [date] NULL,
	[CommRate] [money] NULL,
	[CommRateBand] [varchar](9) NULL,
	[CommissionRatePolicyPrice] [numeric](15, 9) NULL,
	[Commission] [money] NULL,
	[Sales] [money] NULL,
	[PolicyCount] [int] NULL,
	[ModeCommRateBand] [varchar](9) NULL,
	[RecCount] [int] NULL
) ON [PRIMARY]
GO
