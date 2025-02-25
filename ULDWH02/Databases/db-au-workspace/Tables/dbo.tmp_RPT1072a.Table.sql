USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_RPT1072a]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_RPT1072a](
	[PolicyNumber] [varchar](50) NULL,
	[IssueDate] [datetime] NOT NULL,
	[PolicyTravellerID] [int] NOT NULL,
	[CustomerName] [nvarchar](201) NULL,
	[isPrimary] [bit] NULL,
	[CustomerAddress] [nvarchar](252) NULL,
	[NumberOfAdults] [int] NOT NULL,
	[NumberOfChildren] [int] NOT NULL,
	[CustomerAge] [int] NULL,
	[TravelDuration] [int] NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[AreaOfTravel] [nvarchar](100) NULL,
	[CountryOfTravel] [nvarchar](max) NULL,
	[Excess] [money] NOT NULL,
	[EMCScore] [decimal](38, 2) NULL,
	[AddOnGroup] [nvarchar](50) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
