USE [db-au-stage]
GO
/****** Object:  Table [dbo].[SUN_G_SALFLDG]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SUN_G_SALFLDG](
	[Account_Code] [varchar](50) NOT NULL,
	[Ledger_Analysis_T0] [varchar](50) NOT NULL,
	[Ledger_Analysis_T1] [varchar](50) NOT NULL,
	[Ledger_Analysis_T2] [varchar](50) NOT NULL,
	[Ledger_Analysis_T3] [varchar](50) NOT NULL,
	[Ledger_Analysis_T4] [varchar](50) NOT NULL,
	[Ledger_Analysis_T5] [varchar](50) NOT NULL,
	[Ledger_Analysis_T6] [varchar](50) NOT NULL,
	[Ledger_Analysis_T7] [varchar](50) NOT NULL,
	[Ledger_Analysis_T8] [varchar](50) NOT NULL,
	[Ledger_Analysis_T9] [varchar](50) NOT NULL,
	[Business_Unit_Code] [varchar](50) NOT NULL,
	[Scenario_GL_Code] [varchar](50) NOT NULL,
	[Period] [int] NOT NULL,
	[Transaction_Date] [datetime] NOT NULL,
	[Entry_Date] [datetime] NULL,
	[Due_Date] [datetime] NULL,
	[Posting_Date] [datetime] NULL,
	[Originated_Date] [datetime] NULL,
	[After_Posting_Date] [datetime] NULL,
	[Base_Rate] [numeric](18, 9) NOT NULL,
	[Conversion_Rate] [numeric](18, 9) NOT NULL,
	[Reversal] [varchar](3) NOT NULL,
	[Journal_Number] [int] NOT NULL,
	[Journal_Line] [int] NOT NULL,
	[Journal_Type] [varchar](50) NULL,
	[Journal_Source] [varchar](50) NOT NULL,
	[General_Ledger_Amount] [numeric](18, 3) NOT NULL,
	[Report_Amount] [numeric](18, 3) NOT NULL,
	[Other_Amount] [numeric](18, 3) NOT NULL,
	[Debit_Credit_Indicator] [varchar](3) NOT NULL,
	[Allocation_Marker] [varchar](3) NOT NULL,
	[Treference] [varchar](50) NULL,
	[Description] [varchar](50) NULL
) ON [PRIMARY]
GO
