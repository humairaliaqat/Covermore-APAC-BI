USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[UK_Halo_SuperGroup_2_Bak]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UK_Halo_SuperGroup_2_Bak](
	[Agency Name] [nvarchar](255) NULL,
	[Customer Policy Number] [nvarchar](255) NULL,
	[Transaction Date] [smalldatetime] NULL,
	[Inception Date] [smalldatetime] NULL,
	[Expiry Date] [smalldatetime] NULL,
	[Type Of Product] [nvarchar](255) NULL,
	[Days Cover] [float] NULL,
	[Currency] [nvarchar](255) NULL,
	[Product Name] [nvarchar](255) NULL,
	[Gross Premium Exc Taxes] [float] NULL,
	[GST Cost] [float] NULL,
	[Stamp Duty] [float] NULL,
	[Gross Premium Inc Taxes] [float] NULL,
	[Underwriter Costs] [float] NULL,
	[Net Commission to Halo] [float] NULL,
	[Cancelled] [nvarchar](255) NULL,
	[Insured Name] [nvarchar](255) NULL,
	[Insured Date of Birth] [smalldatetime] NULL,
	[Underwriter Name] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL,
	[Country Of Residence] [nvarchar](255) NULL,
	[Auto Renewals] [nvarchar](255) NULL,
	[Charged To Customer] [float] NULL,
	[Admin Fee] [float] NULL,
	[Transaction Type] [nvarchar](255) NULL,
	[Transaction ID] [nvarchar](255) NULL,
	[Stripe ID] [nvarchar](255) NULL,
	[Manual Transfer] [nvarchar](255) NULL,
	[MTA Category] [nvarchar](255) NULL,
	[Payment Status] [nvarchar](255) NULL,
	[Payment Status Error] [nvarchar](255) NULL,
	[TN Check] [nvarchar](255) NULL
) ON [PRIMARY]
GO
