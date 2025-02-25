USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblProduct_aucm]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblProduct_aucm](
	[ProductId] [int] NOT NULL,
	[PurchasePathID] [int] NOT NULL,
	[ProductCode] [nvarchar](50) NOT NULL,
	[ProductName] [nvarchar](50) NOT NULL,
	[ProductDisplayName] [nvarchar](50) NULL,
	[IsCancellation] [bit] NOT NULL,
	[DomainId] [int] NOT NULL,
	[FinanceProductId] [int] NULL,
	[MinimumTripCost] [money] NULL,
	[CoolingOffPeriod] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblProduct_aucm_ProductID]    Script Date: 24/02/2025 5:08:06 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblProduct_aucm_ProductID] ON [dbo].[penguin_tblProduct_aucm]
(
	[ProductId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
