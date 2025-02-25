USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPolicyAddOn_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPolicyAddOn_ukcm](
	[ID] [int] NOT NULL,
	[PolicyTransactionID] [int] NOT NULL,
	[AddOnID] [int] NOT NULL,
	[AddOnValueID] [int] NOT NULL,
	[AddOnGroup] [nvarchar](50) NULL,
	[AddOnText] [nvarchar](500) NULL,
	[CoverIncrease] [money] NOT NULL,
	[IsRatecardBased] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblPolicyAddon_ukcm_ID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblPolicyAddon_ukcm_ID] ON [dbo].[penguin_tblPolicyAddOn_ukcm]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
