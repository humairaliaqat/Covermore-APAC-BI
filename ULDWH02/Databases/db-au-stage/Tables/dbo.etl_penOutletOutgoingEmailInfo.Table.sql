USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_penOutletOutgoingEmailInfo]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_penOutletOutgoingEmailInfo](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](5) NULL,
	[OutletKey] [varchar](71) NULL,
	[OutletID] [int] NOT NULL,
	[EmailTypeID] [int] NOT NULL,
	[EmailType] [nvarchar](50) NULL,
	[EmailSubject] [nvarchar](250) NOT NULL,
	[EmailFromDisplayName] [nvarchar](50) NULL,
	[EmailFromAddress] [varchar](50) NOT NULL,
	[EmailCertOnPurchase] [bit] NULL
) ON [PRIMARY]
GO
