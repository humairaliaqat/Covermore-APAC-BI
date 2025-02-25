USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[indiastatement]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[indiastatement](
	[Invoice No] [varchar](30) NULL,
	[Passenger Name] [varchar](50) NULL,
	[Certificate No] [varchar](30) NULL,
	[Date Of Issue] [datetime] NULL,
	[Trawelltag Fees] [decimal](38, 4) NULL,
	[Service Tax] [decimal](38, 4) NULL,
	[Net Charges] [decimal](38, 4) NULL,
	[Upfront Comm] [decimal](38, 4) NULL,
	[TDS] [decimal](38, 4) NULL,
	[Net Comm] [decimal](38, 4) NULL,
	[Discount] [decimal](38, 4) NULL,
	[Cancellation Charges] [decimal](38, 4) NULL,
	[Service Tax Canx] [decimal](38, 4) NULL,
	[Credit Note] [varchar](30) NOT NULL,
	[Debtor Code] [varchar](30) NULL,
	[Branch Code] [varchar](30) NULL,
	[Branch Name] [varchar](50) NULL,
	[Account Name] [varchar](max) NULL,
	[Net Bill] [decimal](38, 4) NULL,
	[Opening Balance] [decimal](20, 4) NULL,
	[Closing Balance] [decimal](20, 4) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
