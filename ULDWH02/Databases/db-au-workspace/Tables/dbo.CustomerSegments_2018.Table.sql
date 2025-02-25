USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[CustomerSegments_2018]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerSegments_2018](
	[AgeGroup] [varchar](12) NOT NULL,
	[ABSAgeBand] [nvarchar](50) NOT NULL,
	[Gender] [nvarchar](7) NULL,
	[State] [nvarchar](100) NULL,
	[LocationProfile] [varchar](50) NULL,
	[DestinationGroup] [varchar](50) NULL,
	[RiskProfile] [varchar](50) NULL,
	[BrandAffiliation] [varchar](50) NULL,
	[TravelGroup] [varchar](50) NULL,
	[ProductPreference] [varchar](50) NULL,
	[ChannelPreference] [varchar](50) NULL,
	[TravelPattern] [varchar](50) NULL,
	[CustomerCount] [int] NULL,
	[PolicyCount] [int] NULL,
	[TotalSpending] [money] NULL,
	[EMCCount] [int] NULL,
	[LuggageCount] [int] NULL,
	[MedicalCount] [int] NULL,
	[MotorcycleCount] [int] NULL,
	[RentalCarCount] [int] NULL,
	[WintersportCount] [int] NULL
) ON [PRIMARY]
GO
