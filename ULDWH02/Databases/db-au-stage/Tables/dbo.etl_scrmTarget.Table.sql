USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_scrmTarget]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_scrmTarget](
	[UniqueIdentifier] [nvarchar](27) NOT NULL,
	[Date] [datetime] NULL,
	[SalesTarget] [float] NOT NULL,
	[PolicyCount] [float] NOT NULL,
	[CurrencyCode] [char](3) NULL
) ON [PRIMARY]
GO
