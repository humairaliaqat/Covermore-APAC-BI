USE [db-au-workspace]
GO
/****** Object:  Table [COVERMORE\gitesh.shiraskar].[refundworkingdata]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [COVERMORE\gitesh.shiraskar].[refundworkingdata](
	[Countrykey] [varchar](2) NOT NULL,
	[CompanyKey] [varchar](5) NOT NULL,
	[PolicyNumber] [varchar](50) NULL,
	[PolicyStatusDescription] [nvarchar](50) NULL,
	[Firstname] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[IssueDate] [datetime] NOT NULL,
	[DepartureDate] [datetime] NULL,
	[DepartureMonth] [nvarchar](4000) NULL,
	[PolicyStart] [datetime] NOT NULL,
	[PolicyEnd] [datetime] NOT NULL,
	[Destination] [nvarchar](max) NULL,
	[GrossPremium] [money] NULL,
	[TotalCommission] [money] NULL,
	[TotalNet] [money] NULL,
	[ResidualPremiumGross] [money] NULL,
	[ResidualPremiumNett] [money] NULL,
	[ResidualCommission] [money] NULL,
	[EmailAddress] [nvarchar](255) NULL,
	[MobilePhone] [varchar](50) NULL,
	[AlphaCode] [nvarchar](60) NULL,
	[OutletName] [nvarchar](50) NULL,
	[OutletSuperGroup] [nvarchar](255) NULL,
	[OutletSubGroupName] [nvarchar](50) NULL,
	[TripType] [nvarchar](50) NULL,
	[JVCode] [nvarchar](20) NULL,
	[StatusDesc] [varchar](50) NULL,
	[CatastropheCode] [varchar](3) NULL,
	[PaymentMode] [nvarchar](20) NULL,
	[TransactionDate] [datetime] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
