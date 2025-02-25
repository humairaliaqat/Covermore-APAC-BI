USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPromoSubGroupProduct_ukcm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPromoSubGroupProduct_ukcm](
	[PromoID] [int] NOT NULL,
	[SubGroupID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[ID] [int] NOT NULL,
	[SelectAllPlans] [bit] NOT NULL,
	[SelectAllAlphas] [bit] NOT NULL
) ON [PRIMARY]
GO
