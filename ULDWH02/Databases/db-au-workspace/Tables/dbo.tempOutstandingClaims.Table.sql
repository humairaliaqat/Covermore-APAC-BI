USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tempOutstandingClaims]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tempOutstandingClaims](
	[CountryKey] [varchar](5) NULL,
	[ClaimNo] [int] NULL,
	[MonthID] [int] NULL,
	[PolicyProduct] [varchar](50) NULL,
	[AvgOutstandingAge] [float] NULL,
	[OutstandingCount] [int] NULL
) ON [PRIMARY]
GO
