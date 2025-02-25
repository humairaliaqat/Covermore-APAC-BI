USE [db-au-star]
GO
/****** Object:  Table [dbo].[Fact_GL_ind]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Fact_GL_ind](
	[Fact_GL_ID] [bigint] IDENTITY(1,1) NOT NULL,
	[Account_SID] [int] NULL,
	[Business_Unit_SK] [int] NULL,
	[Channel_SK] [int] NULL,
	[Currency_SK] [int] NULL,
	[Joint_Venture_SK] [int] NULL,
	[Department_SK] [int] NULL,
	[Date_SK] [int] NULL,
	[Fiscal_Period_Code] [int] NOT NULL,
	[Scenario_SK] [int] NULL,
	[Source_Business_Unit_SK] [int] NULL,
	[Client_SK] [int] NULL,
	[GL_Product_SK] [int] NULL,
	[Project_Codes_SK] [int] NULL,
	[State_SK] [int] NULL,
	[Journal_Type_SK] [int] NULL,
	[GST_SK] [int] NULL,
	[General_Ledger_Amount] [numeric](18, 3) NULL,
	[Report_Amount] [numeric](18, 3) NULL,
	[Other_Amount] [numeric](18, 3) NULL,
	[Create_Date] [datetime] NOT NULL,
	[Insert_Batch_ID] [int] NOT NULL,
	[Update_Batch_ID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [PK_Fact_GL_ind]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED INDEX [PK_Fact_GL_ind] ON [dbo].[Fact_GL_ind]
(
	[Fact_GL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [period_ind]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [period_ind] ON [dbo].[Fact_GL_ind]
(
	[Fiscal_Period_Code] ASC,
	[Business_Unit_SK] ASC,
	[Scenario_SK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
