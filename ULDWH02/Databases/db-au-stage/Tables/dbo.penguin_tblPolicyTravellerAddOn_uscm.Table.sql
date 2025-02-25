USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPolicyTravellerAddOn_uscm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPolicyTravellerAddOn_uscm](
	[ID] [int] NOT NULL,
	[PolicyTravellerTransactionID] [int] NOT NULL,
	[AddOnID] [int] NOT NULL,
	[AddOnValueID] [int] NOT NULL,
	[AddOnGroup] [nvarchar](50) NULL,
	[AddOnText] [nvarchar](500) NULL,
	[CoverIncrease] [money] NOT NULL,
	[IsRatecardBased] [bit] NOT NULL
) ON [PRIMARY]
GO
