USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_dimConsultant]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_dimConsultant](
	[Country] [varchar](2) NOT NULL,
	[ConsultantKey] [varchar](41) NULL,
	[OutletAlphaKey] [nvarchar](50) NULL,
	[Firstname] [nvarchar](50) NOT NULL,
	[Lastname] [nvarchar](50) NOT NULL,
	[ConsultantName] [nvarchar](101) NOT NULL,
	[UserName] [nvarchar](200) NOT NULL,
	[ASICNumber] [int] NOT NULL,
	[AgreementDate] [datetime] NULL,
	[Status] [varchar](20) NOT NULL,
	[InactiveDate] [datetime] NULL,
	[RefereeName] [nvarchar](255) NOT NULL,
	[AccreditationDate] [datetime] NULL,
	[DeclaredDate] [datetime] NULL,
	[PreviouslyKnownAs] [nvarchar](100) NOT NULL,
	[YearsOfExperience] [varchar](15) NOT NULL,
	[DateOfBirth] [datetime] NULL,
	[ASICCheck] [nvarchar](50) NOT NULL,
	[Email] [nvarchar](200) NOT NULL,
	[FirstSellDate] [datetime] NULL,
	[LastSellDate] [datetime] NULL,
	[ConsultantType] [nvarchar](50) NOT NULL,
	[LoadDate] [datetime] NULL,
	[updateDate] [datetime] NULL,
	[LoadID] [int] NULL,
	[updateID] [int] NULL,
	[HashKey] [varbinary](30) NULL
) ON [PRIMARY]
GO
