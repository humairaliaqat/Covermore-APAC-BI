USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPolicyEMC_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPolicyEMC_ukcm](
	[ID] [int] NOT NULL,
	[PolicyTravellerTransactionID] [int] NOT NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NOT NULL,
	[LastName] [nvarchar](100) NOT NULL,
	[DOB] [datetime] NOT NULL,
	[EMCRef] [varchar](100) NOT NULL,
	[EMCScore] [numeric](10, 4) NULL,
	[PremiumIncrease] [numeric](18, 5) NULL,
	[IsPercentage] [bit] NULL,
	[AddOnId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblPolicyEMC_ukcm_PolicyTravellerTransactionID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_penguin_tblPolicyEMC_ukcm_PolicyTravellerTransactionID] ON [dbo].[penguin_tblPolicyEMC_ukcm]
(
	[PolicyTravellerTransactionID] ASC
)
INCLUDE([EMCRef],[EMCScore],[AddOnId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
