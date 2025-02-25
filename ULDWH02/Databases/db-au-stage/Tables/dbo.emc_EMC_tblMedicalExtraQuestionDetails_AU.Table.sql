USE [db-au-stage]
GO
/****** Object:  Table [dbo].[emc_EMC_tblMedicalExtraQuestionDetails_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[emc_EMC_tblMedicalExtraQuestionDetails_AU](
	[ExtraQidDts] [int] NOT NULL,
	[ClientId] [int] NULL,
	[QId] [tinyint] NULL,
	[QVal] [bit] NULL,
	[RXTypeID] [tinyint] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_emc_EMC_tblMedicalExtraQuestionDetails_AU_ClientID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_emc_EMC_tblMedicalExtraQuestionDetails_AU_ClientID] ON [dbo].[emc_EMC_tblMedicalExtraQuestionDetails_AU]
(
	[ClientId] ASC
)
INCLUDE([QId],[QVal]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
