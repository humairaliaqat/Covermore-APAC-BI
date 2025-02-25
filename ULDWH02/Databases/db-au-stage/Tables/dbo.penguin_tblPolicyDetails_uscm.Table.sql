USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPolicyDetails_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPolicyDetails_uscm](
	[ID] [int] NOT NULL,
	[PolicyID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[UniquePlanID] [int] NOT NULL,
	[Excess] [money] NOT NULL,
	[AreaName] [nvarchar](100) NULL,
	[PolicyStart] [datetime] NOT NULL,
	[PolicyEnd] [datetime] NOT NULL,
	[DaysCovered] [int] NULL,
	[MaxDuration] [int] NULL,
	[PlanName] [nvarchar](50) NULL,
	[PlanType] [nvarchar](50) NULL,
	[PlanID] [int] NULL,
	[TripDuration] [int] NULL,
	[EmailConsent] [bit] NULL,
	[ShowDiscount] [bit] NULL,
	[AreaCode] [nvarchar](3) NULL,
	[IsUnbundled] [bit] NULL,
	[IsCustomerAgreedToEMCPremium] [bit] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblPolicyDetails_uscm_PolicyID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblPolicyDetails_uscm_PolicyID] ON [dbo].[penguin_tblPolicyDetails_uscm]
(
	[PolicyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
