USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_claims_benefit]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_claims_benefit](
	[CountryKey] [varchar](2) NULL,
	[BenefitSectionKey] [varchar](33) NULL,
	[BenefitSectionID] [int] NOT NULL,
	[BenefitCode] [varchar](25) NULL,
	[BenefitDesc] [nvarchar](255) NULL,
	[ProductCode] [varchar](5) NULL,
	[BenefitValidFrom] [datetime] NULL,
	[BenefitValidTo] [datetime] NULL,
	[BenefitLimit] [money] NULL,
	[PrintOrder] [smallint] NULL,
	[CommonCategory] [varchar](10) NULL
) ON [PRIMARY]
GO
