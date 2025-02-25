USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_Wesptac_CreditCard_Trans]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_Wesptac_CreditCard_Trans](
	[Community Code] [varchar](50) NULL,
	[Business Code] [varchar](50) NULL,
	[Business Name] [varchar](50) NULL,
	[Source] [varchar](50) NULL,
	[Order Type] [varchar](50) NULL,
	[Receipt Number] [varchar](50) NULL,
	[Customer Reference Number] [varchar](50) NULL,
	[Customer Number] [varchar](50) NULL,
	[Payment Reference] [varchar](50) NULL,
	[Total Amount] [varchar](50) NULL,
	[Payment Amount] [varchar](50) NULL,
	[Surcharge Amount] [varchar](50) NULL,
	[Currency] [varchar](50) NULL,
	[Settlement Date] [varchar](50) NULL,
	[Transaction Date Time] [varchar](50) NULL,
	[Transaction Status] [varchar](50) NULL,
	[Summary Code] [varchar](50) NULL,
	[Transaction Status Description] [varchar](50) NULL,
	[Authorisation Code] [varchar](50) NULL,
	[Settlement Account Name] [varchar](50) NULL,
	[Payment Instrument] [varchar](50) NULL,
	[Account Type] [varchar](50) NULL,
	[Customer Account Business Code] [varchar](50) NULL,
	[Credit Card Scheme] [varchar](50) NULL,
	[Credit Card Number] [varchar](50) NULL,
	[Credit Card Expiry Date] [varchar](50) NULL,
	[Cardholder Name] [varchar](50) NULL,
	[Bank Account Name] [varchar](50) NULL,
	[Bank Account BSB] [varchar](50) NULL,
	[Bank Account Number] [varchar](50) NULL,
	[Bank Account Bank Code] [varchar](50) NULL,
	[Bank Account Branch Code] [varchar](50) NULL,
	[Bank Account Suffix] [varchar](50) NULL,
	[Login Name] [varchar](50) NULL,
	[Full Name] [varchar](50) NULL,
	[Comment] [varchar](50) NULL,
	[Related Transaction Receipt Number] [varchar](50) NULL,
	[Fraud Guard Result] [varchar](50) NULL
) ON [PRIMARY]
GO
