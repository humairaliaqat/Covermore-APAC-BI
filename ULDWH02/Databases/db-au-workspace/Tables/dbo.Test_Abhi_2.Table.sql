USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Test_Abhi_2]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Test_Abhi_2](
	[PostingDate] [datetime] NULL,
	[PolicyNumber] [varchar](50) NULL,
	[TransactionType] [varchar](50) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[TransactionStatus] [nvarchar](50) NULL,
	[TransactionDateTime] [datetime] NULL,
	[IssueDate] [datetime] NULL,
	[PrimaryCountry] [nvarchar](max) NULL,
	[AreaName] [nvarchar](100) NULL,
	[AreaNumber] [varchar](20) NULL,
	[AreaType] [varchar](25) NULL,
	[TripStart] [datetime] NULL,
	[TripEnd] [datetime] NULL,
	[MaxDuration] [int] NULL,
	[TripType] [nvarchar](50) NULL,
	[PlanCode] [nvarchar](50) NULL,
	[PlanName] [nvarchar](50) NULL,
	[SingleFamilyFlag] [int] NULL,
	[AdultsCount] [int] NULL,
	[ChildrenCount] [int] NULL,
	[TravellersCount] [int] NULL,
	[Excess] [money] NULL,
	[TripCost] [nvarchar](50) NULL,
	[BasePremium] [money] NULL,
	[Title] [nvarchar](50) NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[MobilePhone] [varchar](50) NULL,
	[State] [nvarchar](100) NULL,
	[DOB] [datetime] NULL,
	[Age] [int] NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[OutletName] [nvarchar](50) NULL,
	[Channel] [nvarchar](100) NULL,
	[PromoCode] [nvarchar](10) NULL,
	[Discount] [numeric](10, 4) NULL,
	[Commission] [money] NULL,
	[NewPolicyCount] [int] NULL,
	[Copy of PrimaryCountry] [nvarchar](50) NULL,
	[Copy of FirstName] [nvarchar](100) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
