USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[FinCoil]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinCoil](
	[Sr# No#] [float] NULL,
	[Channel] [nvarchar](255) NULL,
	[Business] [nvarchar](255) NULL,
	[Campaign ID] [float] NULL,
	[Template Change Required (Yes/No)] [nvarchar](255) NULL,
	[Campaign Name] [nvarchar](255) NULL,
	[Product Code] [nvarchar](255) NULL,
	[Template Path ] [nvarchar](255) NULL,
	[Business to confirm if we can remove Special Excess] [nvarchar](255) NULL,
	[Count of sales for Dec'24 month] [float] NULL,
	[BI DWH Count] [float] NULL,
	[BI Comments] [nvarchar](255) NULL,
	[Comments from Product] [nvarchar](255) NULL,
	[Comments from Jenny Edwards] [nvarchar](255) NULL,
	[IT] [nvarchar](255) NULL,
	[Avg Daily Volume (Last 6 months)] [float] NULL,
	[Average Monthly Volume (Last 6 months)] [float] NULL,
	[Impact Start Date] [nvarchar](255) NULL,
	[Total count of Policy impacted till date] [float] NULL,
	[Business Sign off Date] [nvarchar](255) NULL,
	[Business Sign off Received from] [nvarchar](255) NULL
) ON [PRIMARY]
GO
