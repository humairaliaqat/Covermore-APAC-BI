USE [db-au-star]
GO
/****** Object:  Table [dbo].[dimconsultant_test]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dimconsultant_test](
	[ConsultantSK] [int] IDENTITY(1,1) NOT NULL,
	[Country] [nvarchar](10) NOT NULL,
	[ConsultantKey] [nvarchar](50) NOT NULL,
	[OutletAlphaKey] [nvarchar](50) NOT NULL,
	[Firstname] [nvarchar](50) NULL,
	[Lastname] [nvarchar](50) NULL,
	[ConsultantName] [nvarchar](100) NULL,
	[UserName] [nvarchar](100) NULL,
	[ASICNumber] [int] NULL,
	[AgreementDate] [datetime] NULL,
	[Status] [nvarchar](20) NULL,
	[InactiveDate] [datetime] NULL,
	[RefereeName] [nvarchar](255) NULL,
	[AccreditationDate] [datetime] NULL,
	[DeclaredDate] [datetime] NULL,
	[PreviouslyKnownAs] [nvarchar](100) NULL,
	[YearsOfExperience] [nvarchar](15) NULL,
	[DateOfBirth] [datetime] NULL,
	[ASICCheck] [nvarchar](50) NULL,
	[Email] [nvarchar](200) NULL,
	[FirstSellDate] [datetime] NULL,
	[LastSellDate] [datetime] NULL,
	[ConsultantType] [nvarchar](50) NULL,
	[LoadDate] [datetime] NOT NULL,
	[updateDate] [datetime] NULL,
	[LoadID] [int] NOT NULL,
	[updateID] [int] NULL,
	[HashKey] [varbinary](30) NULL
) ON [PRIMARY]
GO
