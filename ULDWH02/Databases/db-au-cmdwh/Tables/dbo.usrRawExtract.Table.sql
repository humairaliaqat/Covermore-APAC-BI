USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrRawExtract]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrRawExtract](
	[ID] [int] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Country] [varchar](2) NULL,
	[AgencyGroup] [varchar](2) NULL,
	[Procs] [varchar](max) NULL,
	[isActive] [bit] NOT NULL,
	[dumpOutput] [bit] NOT NULL,
	[OutputPath] [varchar](max) NULL,
	[logOutput] [bit] NOT NULL,
	[LogTable] [varchar](64) NULL,
	[verifyBackup] [bit] NOT NULL,
	[BackupPath] [varchar](64) NULL,
	[replaceLog] [bit] NOT NULL,
	[CompressOutput] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrRawExtract_Name]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrRawExtract_Name] ON [dbo].[usrRawExtract]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[usrRawExtract] ADD  CONSTRAINT [DF_usrRawExtract_isActive]  DEFAULT ((1)) FOR [isActive]
GO
ALTER TABLE [dbo].[usrRawExtract] ADD  DEFAULT ((0)) FOR [dumpOutput]
GO
ALTER TABLE [dbo].[usrRawExtract] ADD  CONSTRAINT [DF_usrRawExtract_logOutput]  DEFAULT ((0)) FOR [logOutput]
GO
ALTER TABLE [dbo].[usrRawExtract] ADD  CONSTRAINT [DF_usrRawExtract_verifyBackup]  DEFAULT ((0)) FOR [verifyBackup]
GO
ALTER TABLE [dbo].[usrRawExtract] ADD  CONSTRAINT [DF_usrRawExtract_replaceLog]  DEFAULT ((0)) FOR [replaceLog]
GO
ALTER TABLE [dbo].[usrRawExtract] ADD  CONSTRAINT [DF_usrRawExtract_CompressOutput]  DEFAULT ((0)) FOR [CompressOutput]
GO
