USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_corpBenefit]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_corpBenefit](
	[CountryKey] [varchar](2) NOT NULL,
	[BenefitKey] [varchar](10) NULL,
	[BenefitID] [int] NOT NULL,
	[BenefitCode] [varchar](3) NULL,
	[BenefitDesc] [varchar](200) NULL,
	[ValidFrom] [datetime] NULL,
	[ValidTo] [datetime] NULL
) ON [PRIMARY]
GO
