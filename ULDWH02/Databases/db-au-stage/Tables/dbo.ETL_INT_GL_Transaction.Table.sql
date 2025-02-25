USE [db-au-stage]
GO
/****** Object:  Table [dbo].[ETL_INT_GL_Transaction]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_INT_GL_Transaction](
	[Scenario_GL_Code] [varchar](50) NULL,
	[Account_Code] [varchar](50) NULL,
	[Business_Unit_Code] [varchar](50) NULL,
	[Period] [int] NULL,
	[Transaction_Date] [date] NULL,
	[Entry_Date] [date] NULL,
	[Due_Date] [date] NULL,
	[Posting_Date] [date] NULL,
	[Originated_Date] [date] NULL,
	[After_Posting_Date] [date] NULL,
	[Base_Rate] [numeric](18, 9) NULL,
	[Conversion_Rate] [numeric](18, 9) NULL,
	[Reversal_Indicator] [varchar](3) NULL,
	[Journal_Number] [int] NULL,
	[Journal_Line] [varchar](50) NULL,
	[Journal_Type] [varchar](50) NULL,
	[Journal_Source] [varchar](50) NULL,
	[General_Ledger_Amount] [numeric](18, 3) NULL,
	[Report_Amount] [numeric](18, 3) NULL,
	[Other_Amount] [numeric](18, 3) NULL,
	[Debit_Credit_Indicator] [varchar](3) NULL,
	[Allocation_Marker] [varchar](3) NULL,
	[Txn_Reference] [varchar](50) NULL,
	[Txn_Description] [varchar](50) NULL,
	[BDM_Code] [varchar](50) NULL,
	[Business_Code] [varchar](50) NULL,
	[Channel_Code] [varchar](50) NULL,
	[Client_Code] [varchar](50) NULL,
	[Department_Code] [varchar](50) NULL,
	[Joint_Venture_Code] [varchar](50) NULL,
	[Product_Code] [varchar](50) NULL,
	[Project_Code] [varchar](50) NULL,
	[Source_Code] [varchar](50) NULL,
	[State_Code] [varchar](50) NULL,
	[Case_Number] [varchar](50) NULL
) ON [PRIMARY]
GO
