USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_excel_salesforce]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_excel_salesforce](
	[Country] [nvarchar](255) NULL,
	[DomainID] [int] NULL,
	[BDMName] [nvarchar](255) NULL,
	[FullName] [nvarchar](255) NULL,
	[PositionTitle] [nvarchar](255) NULL,
	[DistributorManager] [nvarchar](255) NULL,
	[TerritoryManager] [nvarchar](255) NULL,
	[NationalManager] [nvarchar](255) NULL
) ON [PRIMARY]
GO
