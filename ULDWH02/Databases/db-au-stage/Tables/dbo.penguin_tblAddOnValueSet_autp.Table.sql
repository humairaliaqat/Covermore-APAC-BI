USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblAddOnValueSet_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblAddOnValueSet_autp](
	[AddOnValueSetID] [int] NOT NULL,
	[PlanID] [int] NOT NULL,
	[AddOnID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[MaxCover] [money] NULL,
	[IsPolicyAddon] [bit] NOT NULL,
	[IsSelectPerTraveller] [bit] NOT NULL
) ON [PRIMARY]
GO
