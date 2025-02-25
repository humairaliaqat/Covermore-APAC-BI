USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cisCallMetaData]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisCallMetaData](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[MetaDataID] [bigint] NOT NULL,
	[SessionKey] [nvarchar](50) NULL,
	[SessionID] [numeric](18, 0) NULL,
	[CallType] [varchar](10) NULL,
	[LocalStartTime] [datetime] NULL,
	[Duration] [int] NULL,
	[Username] [nvarchar](60) NULL,
	[isTraining] [bit] NULL,
	[isInbound] [bit] NULL,
	[Team] [nvarchar](60) NULL,
	[CompanyGroup] [nvarchar](60) NULL,
	[Phone] [nvarchar](70) NULL,
	[CCRef] [nvarchar](2056) NULL,
	[EMCRef] [nvarchar](2056) NULL,
	[ClaimRef] [nvarchar](2056) NULL,
	[PolicyRef] [nvarchar](2056) NULL,
	[CaseKey] [nvarchar](20) NULL,
	[ApplicationKey] [varchar](15) NULL,
	[ClaimKey] [varchar](40) NULL,
	[PolicyTransactionKey] [varchar](41) NULL,
	[isRecordingAvailable] [bit] NULL,
	[ForcedAUPhone] [varchar](20) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cisCallMetaData_BIRowID]    Script Date: 24/02/2025 12:39:34 PM ******/
CREATE CLUSTERED INDEX [idx_cisCallMetaData_BIRowID] ON [dbo].[cisCallMetaData]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cisCallMetaData_ForcedAUPhone]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisCallMetaData_ForcedAUPhone] ON [dbo].[cisCallMetaData]
(
	[ForcedAUPhone] ASC
)
INCLUDE([MetaDataID],[Duration],[LocalStartTime],[Phone]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cisCallMetaData_LocalStartTime]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisCallMetaData_LocalStartTime] ON [dbo].[cisCallMetaData]
(
	[LocalStartTime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cisCallMetaData_MetaDataID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisCallMetaData_MetaDataID] ON [dbo].[cisCallMetaData]
(
	[MetaDataID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_cisCallMetaData_PolicyTransactionKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cisCallMetaData_PolicyTransactionKey] ON [dbo].[cisCallMetaData]
(
	[PolicyTransactionKey] ASC
)
INCLUDE([LocalStartTime],[Duration],[Username],[Phone]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
