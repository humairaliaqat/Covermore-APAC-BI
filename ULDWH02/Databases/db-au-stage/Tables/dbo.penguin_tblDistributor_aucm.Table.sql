USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblDistributor_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblDistributor_aucm](
	[DistributorId] [int] NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Code] [nvarchar](10) NOT NULL,
	[Urls] [nvarchar](2000) NOT NULL,
	[DistributorAPIKeys] [nvarchar](1000) NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[DomainId] [int] NOT NULL
) ON [PRIMARY]
GO
