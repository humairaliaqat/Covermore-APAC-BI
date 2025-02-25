USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_IAL_Quote]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_IAL_Quote](
	[QuoteID] [int] NULL,
	[SessionID] [nvarchar](255) NULL,
	[AlphaCode] [nvarchar](60) NULL,
	[UserName] [nvarchar](100) NULL,
	[ConsultantName] [nvarchar](101) NULL,
	[QuoteDate] [datetime] NULL,
	[QuoteTime] [datetime] NULL,
	[Area] [nvarchar](50) NULL,
	[Destination] [nvarchar](max) NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[PolicyNumber] [varchar](50) NULL,
	[ChildrenCount] [int] NULL,
	[AdultsCount] [int] NULL,
	[TravellersCount] [int] NULL,
	[Duration] [int] NULL,
	[isSaved] [bit] NULL,
	[QuoteSaveDate] [datetime] NULL,
	[QuotePrice] [numeric](10, 4) NULL,
	[ProductCode] [nvarchar](50) NULL,
	[ProductName] [nvarchar](50) NULL,
	[PlanName] [nvarchar](50) NULL,
	[PlanType] [nvarchar](50) NULL,
	[Excess] [money] NULL,
	[PolicyStart] [datetime] NULL,
	[PolicyEnd] [datetime] NULL,
	[DaysCovered] [int] NULL,
	[isSelected] [bit] NULL,
	[PromoCode] [varchar](10) NULL,
	[PromoName] [nvarchar](250) NULL,
	[PromoType] [nvarchar](50) NULL,
	[PromoDiscount] [numeric](10, 4) NULL,
	[GoBelowNet] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
