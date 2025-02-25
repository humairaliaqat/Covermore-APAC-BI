USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Insured_Tbl]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Insured_Tbl](
	[Policy_Number] [varchar](50) NULL,
	[Transaction_Type] [varchar](50) NULL,
	[Transaction_Sequence_Number] [varchar](41) NULL,
	[Transaction_Status] [nvarchar](50) NULL,
	[Transaction_Date] [varchar](50) NULL,
	[Sold_Date] [varchar](50) NULL,
	[Policy_Holder_First_Name] [varchar](500) NULL,
	[Policy_Holder_Surname] [varchar](500) NULL,
	[Lead_Number] [int] NULL,
	[Rate_Effective_Date] [varchar](50) NULL,
	[Traveller_Sequence_No] [bigint] NULL,
	[Traveller_Title] [varchar](500) NULL,
	[Traveller_DOB] [varchar](50) NULL,
	[Traveller_Age] [int] NULL,
	[Traveller_PEMC_Flag] [varchar](3) NULL,
	[Traveller_Medical_Risk_Score] [varchar](30) NULL,
	[Traveller_PEMC_Assessment_Outcome] [varchar](30) NULL,
	[Traveller_PEMC_Additional_Premium] [money] NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
