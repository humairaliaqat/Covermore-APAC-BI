USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[emcMedicalQuestions]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emcMedicalQuestions](
	[CountryKey] [varchar](2) NOT NULL,
	[MedicalKey] [varchar](15) NOT NULL,
	[MedicalID] [int] NOT NULL,
	[QuestionID] [int] NOT NULL,
	[Question] [varchar](200) NULL,
	[Answer] [varchar](100) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcMedicalQuestions_MedicalKey]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_emcMedicalQuestions_MedicalKey] ON [dbo].[emcMedicalQuestions]
(
	[MedicalKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcMedicalQuestions_QuestionID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_emcMedicalQuestions_QuestionID] ON [dbo].[emcMedicalQuestions]
(
	[QuestionID] ASC,
	[CountryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_emcMedicalQuestions_Questions]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_emcMedicalQuestions_Questions] ON [dbo].[emcMedicalQuestions]
(
	[MedicalKey] ASC
)
INCLUDE([Question],[Answer]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
