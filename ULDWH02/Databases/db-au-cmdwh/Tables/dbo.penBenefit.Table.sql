USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[penBenefit]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penBenefit](
	[CountryKey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[BenefitKey] [varchar](41) NULL,
	[BenefitID] [int] NULL,
	[SortOrder] [int] NULL,
	[DomainID] [int] NULL,
	[DisplayName] [nvarchar](200) NULL,
	[HelpText] [nvarchar](max) NULL,
	[DomainKey] [varchar](41) NULL,
	[BenefitCodeId] [int] NULL,
	[BenefitCoverTypeId] [int] NULL,
	[IsClaimsBenefit] [bit] NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[Status] [varchar](15) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penBenefit_BenefitKey]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_penBenefit_BenefitKey] ON [dbo].[penBenefit]
(
	[BenefitKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
