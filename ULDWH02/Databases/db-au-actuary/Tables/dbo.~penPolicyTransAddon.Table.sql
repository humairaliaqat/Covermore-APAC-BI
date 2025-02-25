USE [db-au-actuary]
GO
/****** Object:  Table [dbo].[~penPolicyTransAddon]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[~penPolicyTransAddon](
	[BIrowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[AddOnGroup] [nvarchar](50) NULL,
	[AddOnText] [nvarchar](500) NULL,
	[CoverIncrease] [money] NULL,
	[GrossPremium] [money] NULL,
	[UnAdjGrossPremium] [money] NULL,
	[AddonCount] [int] NULL,
	[PolicyKey] [varchar](41) NULL
) ON [PRIMARY]
GO
