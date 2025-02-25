USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tbl_recon_analytics_quote]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_recon_analytics_quote](
	[Date] [date] NOT NULL,
	[Partner] [varchar](300) NOT NULL,
	[LowerThreshold] [int] NOT NULL,
	[UpperThreshold] [int] NOT NULL,
	[IncomingDataCount] [int] NOT NULL
) ON [PRIMARY]
GO
