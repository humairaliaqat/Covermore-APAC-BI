USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[cba_data_demo]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cba_data_demo](
	[Date] [datetime] NOT NULL,
	[Channel] [varchar](11) NOT NULL,
	[ShopID] [nvarchar](4000) NULL,
	[ABSDurationBand] [nvarchar](50) NULL,
	[ABSAgeBand] [nvarchar](50) NULL,
	[Continent] [nvarchar](100) NULL,
	[Destination] [nvarchar](50) NULL,
	[Age] [int] NOT NULL,
	[ProductName] [nvarchar](100) NULL,
	[ProductClassification] [nvarchar](100) NULL,
	[PlanType] [nvarchar](50) NULL,
	[TripType] [nvarchar](50) NULL,
	[CancellationCover] [int] NULL,
	[LeadTime] [int] NOT NULL,
	[Excess] [money] NULL,
	[Premium] [float] NULL,
	[SellPrice] [float] NULL,
	[Commission] [float] NULL,
	[PolicyCount] [int] NULL,
	[QuoteCount] [int] NOT NULL
) ON [PRIMARY]
GO
