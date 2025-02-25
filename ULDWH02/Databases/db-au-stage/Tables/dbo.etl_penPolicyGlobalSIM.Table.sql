USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penPolicyGlobalSIM]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penPolicyGlobalSIM](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[PolicyKey] [varchar](71) NULL,
	[AdditionalBenefitKey] [varchar](71) NULL,
	[DomainID] [int] NOT NULL,
	[PolicyId] [int] NOT NULL,
	[AdditionalBenefitID] [int] NOT NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[CreateDateTimeUTC] [datetime] NOT NULL,
	[UpdateDateTimeUTC] [datetime] NOT NULL,
	[Status] [varchar](15) NOT NULL,
	[Comments] [varchar](1000) NULL,
	[FirstName] [varchar](255) NULL,
	[Surname] [varchar](255) NULL,
	[Address] [varchar](255) NULL,
	[Suburb] [varchar](255) NULL,
	[State] [varchar](255) NULL,
	[Postcode] [varchar](255) NULL,
	[Email] [varchar](255) NULL,
	[Mobile] [varchar](255) NULL,
	[TypeOfSimCard] [varchar](255) NULL,
	[ItalyVisit] [varchar](255) NULL
) ON [PRIMARY]
GO
