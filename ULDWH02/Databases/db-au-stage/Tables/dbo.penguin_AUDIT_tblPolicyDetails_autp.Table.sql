USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_AUDIT_tblPolicyDetails_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_AUDIT_tblPolicyDetails_autp](
	[AUDIT_USERNAME] [varchar](255) NULL,
	[AUDIT_RECORDTYPE] [varchar](255) NULL,
	[AUDIT_DATETIME] [datetime] NULL,
	[ID] [int] NOT NULL,
	[AUDIT_tblPolicyDetails_ID] [int] NOT NULL,
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
	[IsUnbundled] [bit] NULL
) ON [PRIMARY]
GO
