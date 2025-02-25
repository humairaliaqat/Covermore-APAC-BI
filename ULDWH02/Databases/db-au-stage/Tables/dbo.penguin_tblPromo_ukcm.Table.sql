USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblPromo_ukcm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblPromo_ukcm](
	[PromoID] [int] NOT NULL,
	[Name] [nvarchar](250) NOT NULL,
	[Code] [varchar](50) NULL,
	[PromoStart] [datetime] NOT NULL,
	[PromoEnd] [datetime] NULL,
	[Discount] [numeric](10, 4) NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[UpdateDateTime] [datetime] NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[PromoTypeID] [int] NOT NULL,
	[IsPercentage] [bit] NOT NULL,
	[DomainId] [int] NOT NULL,
	[SortOrder] [int] NOT NULL,
	[GoBelowNet] [bit] NOT NULL,
	[CommissionType] [int] NULL,
	[IsMoreThanOnePromo] [bit] NOT NULL,
	[MinimumSpend] [numeric](10, 4) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblPromo_ukcm_PromoID]    Script Date: 24/02/2025 5:08:06 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblPromo_ukcm_PromoID] ON [dbo].[penguin_tblPromo_ukcm]
(
	[PromoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
