USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_RPT1072b]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_RPT1072b](
	[SuperGroupName] [nvarchar](25) NULL,
	[GroupName] [nvarchar](50) NOT NULL,
	[SubGroupName] [nvarchar](50) NULL,
	[AgencyName] [nvarchar](50) NOT NULL,
	[AlphaCode] [nvarchar](20) NOT NULL,
	[PolicyNumber] [varchar](50) NULL,
	[IssueDate] [datetime] NOT NULL,
	[ProductName] [nvarchar](50) NULL,
	[PlanName] [nvarchar](100) NULL,
	[BasePremiumExclIPT] [money] NULL,
	[EMCPremium] [money] NULL,
	[OtherAddonPremium] [money] NULL,
	[GrossPremiumExclIPT] [money] NULL,
	[IPT] [money] NULL,
	[GrossPremiumInclIPT] [money] NULL,
	[TravellerCount] [int] NULL,
	[PolicyTravellerID] [int] NOT NULL,
	[CustomerName] [nvarchar](201) NULL,
	[isPrimary] [bit] NULL,
	[Age] [int] NULL,
	[CustomerAddress] [nvarchar](252) NULL,
	[CustomerPostcode] [nvarchar](50) NULL,
	[NumberOfAdults] [int] NULL,
	[NumberOfChildren] [int] NULL,
	[TravelDuration] [int] NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[AreaOfTravel] [nvarchar](100) NULL,
	[CountryOfTravel] [nvarchar](max) NULL,
	[Excess] [money] NOT NULL,
	[AddOnGroup] [nvarchar](50) NULL,
	[AddonCount] [int] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
