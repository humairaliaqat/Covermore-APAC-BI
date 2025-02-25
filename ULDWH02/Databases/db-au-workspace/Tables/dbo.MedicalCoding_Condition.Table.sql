USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[MedicalCoding_Condition]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicalCoding_Condition](
	[ClaimKey] [varchar](40) NOT NULL,
	[Condition] [varchar](50) NULL,
	[ConditionStatus] [varchar](19) NULL,
	[MedicalScore] [numeric](18, 2) NULL,
	[GroupScore] [numeric](18, 2) NULL
) ON [PRIMARY]
GO
