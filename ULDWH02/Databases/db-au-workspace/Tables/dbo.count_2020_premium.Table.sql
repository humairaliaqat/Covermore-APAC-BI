USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[count_2020_premium]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[count_2020_premium](
	[Domain] [varchar](2) NULL,
	[JV] [nvarchar](2) NULL,
	[Channel] [varchar](19) NULL,
	[ProductSK] [int] NOT NULL,
	[Month] [date] NULL,
	[PremiumBudget] [float] NULL
) ON [PRIMARY]
GO
