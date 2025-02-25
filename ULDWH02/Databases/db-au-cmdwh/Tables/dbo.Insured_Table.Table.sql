USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Insured_Table]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Insured_Table](
	[Policy_Number] [varchar](50) NULL,
	[Transaction_Type] [varchar](50) NULL,
	[Transaction_Sequence_Number] [varchar](50) NULL,
	[Transaction_Status] [varchar](50) NULL,
	[Transaction_Date] [varchar](50) NULL,
	[Sold_Date] [varchar](50) NULL,
	[Policy_Holder_First_Name] [varchar](50) NULL,
	[Policy_Holder_Surname] [varchar](50) NULL,
	[Lead_Number] [varchar](50) NULL,
	[Rate_Effective_Date] [varchar](50) NULL,
	[Traveller_Sequence_No] [varchar](50) NULL,
	[Traveller_Title] [varchar](50) NULL,
	[Traveller_DOB] [varchar](50) NULL,
	[Traveller_Age] [varchar](50) NULL,
	[Traveller_PEMC_Flag] [varchar](50) NULL,
	[Traveller_Medical_Risk_Score] [varchar](50) NULL,
	[Traveller_PEMC_Assessment_Outcome] [varchar](50) NULL,
	[Traveller_PEMC_Additional_Premium] [varchar](50) NULL
) ON [PRIMARY]
GO
