USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrCBIncidentFee]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrCBIncidentFee](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CountryKey] [varchar](2) NULL,
	[ClientCode] [varchar](2) NULL,
	[ProgramCode] [varchar](2) NULL,
	[FeeDescription] [varchar](100) NULL,
	[BusinessUnit] [varchar](50) NULL,
	[IncidentType] [varchar](100) NULL,
	[Fee] [money] NOT NULL,
	[GST] [numeric](5, 2) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrCBIncidentFee_BIRowID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE CLUSTERED INDEX [idx_usrCBIncidentFee_BIRowID] ON [dbo].[usrCBIncidentFee]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrCBIncidentFee_ClientCode]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrCBIncidentFee_ClientCode] ON [dbo].[usrCBIncidentFee]
(
	[ClientCode] ASC,
	[ProgramCode] ASC,
	[CountryKey] ASC
)
INCLUDE([IncidentType],[Fee],[GST]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[usrCBIncidentFee] ADD  DEFAULT ((0)) FOR [Fee]
GO
ALTER TABLE [dbo].[usrCBIncidentFee] ADD  DEFAULT ((0)) FOR [GST]
GO
