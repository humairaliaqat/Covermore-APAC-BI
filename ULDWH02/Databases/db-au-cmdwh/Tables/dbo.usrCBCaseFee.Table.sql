USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrCBCaseFee]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrCBCaseFee](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [varchar](2) NULL,
	[ClientCode] [varchar](2) NULL,
	[ProgramCode] [varchar](2) NULL,
	[FeeDescription] [varchar](100) NULL,
	[BusinessUnit] [varchar](50) NULL,
	[DebtorsCode] [varchar](30) NULL,
	[Quotation] [varchar](50) NULL,
	[SimpleMedicalCaseFee] [money] NOT NULL,
	[SimpleTechnicalCaseFee] [money] NOT NULL,
	[MediumMedicalCaseFee] [money] NOT NULL,
	[MediumTechnicalCaseFee] [money] NOT NULL,
	[ComplexMedicalCaseFee] [money] NOT NULL,
	[ComplexTechnicalCaseFee] [money] NOT NULL,
	[EvacuationCaseFee] [money] NOT NULL,
	[GST] [numeric](5, 2) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrCBCaseFee_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_usrCBCaseFee_BIRowID] ON [dbo].[usrCBCaseFee]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrCBCaseFee_ClientCode]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrCBCaseFee_ClientCode] ON [dbo].[usrCBCaseFee]
(
	[ClientCode] ASC,
	[ProgramCode] ASC,
	[CountryKey] ASC
)
INCLUDE([DebtorsCode],[SimpleMedicalCaseFee],[SimpleTechnicalCaseFee],[MediumMedicalCaseFee],[MediumTechnicalCaseFee],[ComplexMedicalCaseFee],[ComplexTechnicalCaseFee],[EvacuationCaseFee],[GST]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[usrCBCaseFee] ADD  DEFAULT ((0)) FOR [SimpleMedicalCaseFee]
GO
ALTER TABLE [dbo].[usrCBCaseFee] ADD  DEFAULT ((0)) FOR [SimpleTechnicalCaseFee]
GO
ALTER TABLE [dbo].[usrCBCaseFee] ADD  DEFAULT ((0)) FOR [MediumMedicalCaseFee]
GO
ALTER TABLE [dbo].[usrCBCaseFee] ADD  DEFAULT ((0)) FOR [MediumTechnicalCaseFee]
GO
ALTER TABLE [dbo].[usrCBCaseFee] ADD  DEFAULT ((0)) FOR [ComplexMedicalCaseFee]
GO
ALTER TABLE [dbo].[usrCBCaseFee] ADD  DEFAULT ((0)) FOR [ComplexTechnicalCaseFee]
GO
ALTER TABLE [dbo].[usrCBCaseFee] ADD  DEFAULT ((0)) FOR [EvacuationCaseFee]
GO
ALTER TABLE [dbo].[usrCBCaseFee] ADD  DEFAULT ((0)) FOR [GST]
GO
