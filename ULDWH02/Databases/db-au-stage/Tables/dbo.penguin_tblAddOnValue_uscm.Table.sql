USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblAddOnValue_uscm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblAddOnValue_uscm](
	[AddOnValueId] [int] NOT NULL,
	[AddOnValueSetID] [int] NULL,
	[Code] [nvarchar](10) NULL,
	[Description] [nvarchar](50) NULL,
	[PremiumIncrease] [numeric](18, 5) NULL,
	[CoverIncrease] [money] NULL,
	[IsPercentage] [bit] NOT NULL,
	[IsDefault] [bit] NULL,
	[IsNotSelected] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblAddonValue_uscm_AddOnValueID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblAddonValue_uscm_AddOnValueID] ON [dbo].[penguin_tblAddOnValue_uscm]
(
	[AddOnValueId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
