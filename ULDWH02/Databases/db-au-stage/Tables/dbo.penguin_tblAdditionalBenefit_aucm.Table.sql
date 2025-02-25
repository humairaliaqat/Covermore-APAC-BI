USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblAdditionalBenefit_aucm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblAdditionalBenefit_aucm](
	[BenefitId] [int] NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
	[Code] [varchar](10) NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[DomainId] [int] NOT NULL
) ON [PRIMARY]
GO
