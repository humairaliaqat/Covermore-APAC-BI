USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblBenefit_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblBenefit_uscm](
	[BenefitId] [int] NOT NULL,
	[Name] [nvarchar](200) NULL,
	[SortOrder] [int] NOT NULL,
	[DomainId] [int] NOT NULL,
	[DisplayName] [nvarchar](200) NOT NULL,
	[HelpText] [nvarchar](max) NOT NULL,
	[BenefitCodeId] [int] NOT NULL,
	[BenefitCoverTypeId] [int] NULL,
	[IsClaimsBenefit] [bit] NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[Status] [varchar](15) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
