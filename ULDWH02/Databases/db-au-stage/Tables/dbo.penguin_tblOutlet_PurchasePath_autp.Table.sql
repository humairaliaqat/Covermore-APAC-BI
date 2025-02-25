USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblOutlet_PurchasePath_autp]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblOutlet_PurchasePath_autp](
	[Id] [int] NOT NULL,
	[OutletId] [int] NOT NULL,
	[PurchasePathId] [int] NOT NULL,
	[IsSelected] [bit] NOT NULL,
	[DefaultCancellationPlanTypeId] [int] NULL,
	[IsCancellation] [bit] NOT NULL
) ON [PRIMARY]
GO
