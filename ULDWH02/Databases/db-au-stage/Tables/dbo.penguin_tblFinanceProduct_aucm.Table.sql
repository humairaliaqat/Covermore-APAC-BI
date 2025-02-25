USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblFinanceProduct_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblFinanceProduct_aucm](
	[FinanceProductId] [int] NOT NULL,
	[Code] [nvarchar](10) NOT NULL,
	[Name] [nvarchar](125) NOT NULL,
	[Status] [nvarchar](15) NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
