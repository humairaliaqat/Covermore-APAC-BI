USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_emcMedicalQuestions]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_emcMedicalQuestions](
	[CountryKey] [varchar](2) NULL,
	[MedicalKey] [varchar](15) NULL,
	[MedicalID] [int] NULL,
	[QuestionID] [int] NOT NULL,
	[Question] [varchar](200) NULL,
	[Answer] [varchar](100) NULL
) ON [PRIMARY]
GO
