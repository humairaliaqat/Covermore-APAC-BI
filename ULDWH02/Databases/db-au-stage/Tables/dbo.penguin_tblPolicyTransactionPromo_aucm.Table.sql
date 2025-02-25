USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPolicyTransactionPromo_aucm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPolicyTransactionPromo_aucm](
	[PolicyTransactionPromoID] [int] NOT NULL,
	[PromoID] [int] NOT NULL,
	[Discount] [numeric](10, 4) NOT NULL,
	[IsApplied] [bit] NOT NULL,
	[ApplyOrder] [smallint] NOT NULL,
	[PolicyTransactionID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblPolicyTransactionPromo_aucm_PolicyTransactionID]    Script Date: 24/02/2025 5:08:06 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblPolicyTransactionPromo_aucm_PolicyTransactionID] ON [dbo].[penguin_tblPolicyTransactionPromo_aucm]
(
	[PolicyTransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
