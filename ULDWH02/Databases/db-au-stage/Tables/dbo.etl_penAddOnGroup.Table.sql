USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penAddOnGroup]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penAddOnGroup](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[AddOnGroupKey] [varchar](71) NULL,
	[AddOnGroupID] [int] NOT NULL,
	[GroupName] [nvarchar](50) NOT NULL,
	[Comments] [nvarchar](50) NULL,
	[GroupCode] [varchar](10) NULL
) ON [PRIMARY]
GO
