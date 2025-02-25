USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penCRMCallComments]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penCRMCallComments](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[DomainKey] [varchar](41) NULL,
	[CRMCallKey] [varchar](71) NULL,
	[OutletKey] [varchar](71) NULL,
	[UserKey] [varchar](71) NULL,
	[CRMUserKey] [varchar](71) NULL,
	[DomainID] [int] NULL,
	[CRMCallID] [int] NOT NULL,
	[OutletID] [int] NOT NULL,
	[CRMUserID] [int] NOT NULL,
	[AlphaCode] [nvarchar](20) NOT NULL,
	[UserID] [int] NULL,
	[Category] [nvarchar](50) NULL,
	[SubCategory] [nvarchar](50) NULL,
	[Duration] [int] NULL,
	[CallDate] [datetime] NULL,
	[CallDateUTC] [datetime] NULL,
	[ActualCallDate] [datetime] NULL,
	[ActualCallDateUTC] [datetime] NULL,
	[CallComments] [varchar](max) NULL,
	[isXora] [bit] NULL,
	[AgencyCallID] [varchar](20) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
