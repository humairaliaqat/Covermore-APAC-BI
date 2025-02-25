USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrRPT0489]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrRPT0489](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[xOutputFileNamex] [varchar](64) NULL,
	[xDataIDx] [varchar](41) NULL,
	[xDataValuex] [money] NOT NULL,
	[Data] [nvarchar](max) NULL,
	[xFailx] [bit] NOT NULL,
	[DataTimeStamp] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_usrRPT0489_BIRowID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE CLUSTERED INDEX [idx_usrRPT0489_BIRowID] ON [dbo].[usrRPT0489]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrRPT0489_DataTimeStamp]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrRPT0489_DataTimeStamp] ON [dbo].[usrRPT0489]
(
	[DataTimeStamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrRPT0489_xDataIDx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrRPT0489_xDataIDx] ON [dbo].[usrRPT0489]
(
	[xDataIDx] ASC,
	[xFailx] ASC,
	[xDataValuex] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrRPT0489_xOutputFileNamex]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrRPT0489_xOutputFileNamex] ON [dbo].[usrRPT0489]
(
	[xOutputFileNamex] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[usrRPT0489] ADD  DEFAULT ((0)) FOR [xDataValuex]
GO
ALTER TABLE [dbo].[usrRPT0489] ADD  DEFAULT ((0)) FOR [xFailx]
GO
ALTER TABLE [dbo].[usrRPT0489] ADD  DEFAULT (getdate()) FOR [DataTimeStamp]
GO
