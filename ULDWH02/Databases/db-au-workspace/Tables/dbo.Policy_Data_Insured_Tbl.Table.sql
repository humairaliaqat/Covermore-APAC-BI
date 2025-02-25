USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Policy_Data_Insured_Tbl]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Policy_Data_Insured_Tbl](
	[Lead_Number] [int] NOT NULL,
	[Policy_Number] [varchar](50) NOT NULL,
	[Transaction_Type] [varchar](50) NOT NULL,
	[Transaction_Sequence_Number] [varchar](41) NOT NULL,
	[Transaction_Status] [nvarchar](50) NOT NULL,
	[Transaction_Date] [varchar](50) NOT NULL,
	[Sold_Date] [varchar](50) NOT NULL,
	[Rate_Effective_Date] [varchar](50) NOT NULL,
	[Traveller_Sequence_No] [bigint] NOT NULL,
	[Traveller_Title] [varchar](500) NULL,
	[Policy_Holder_First_Name] [varchar](500) NULL,
	[Policy_Holder_Surname] [varchar](500) NULL,
	[Traveller_DOB] [varchar](50) NOT NULL,
	[Traveller_Age] [int] NOT NULL,
	[Traveller_PEMC_Flag] [varchar](3) NOT NULL,
	[Traveller_Medical_Risk_Score] [varchar](30) NOT NULL,
	[Traveller_PEMC_Assessment_Outcome] [varchar](30) NOT NULL,
	[Traveller_PEMC_Additional_Premium] [money] NOT NULL
) ON [PRIMARY]
GO
