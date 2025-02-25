USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrRPT0728b]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrRPT0728b](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[xOutputFileNamex] [varchar](64) NULL,
	[xDataIDx] [varchar](41) NULL,
	[xDataValuex] [money] NOT NULL,
	[Data] [nvarchar](max) NULL,
	[xFailx] [bit] NOT NULL,
	[DataTimeStamp] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_usrRPT0728b_BIRowID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE CLUSTERED INDEX [idx_usrRPT0728b_BIRowID] ON [dbo].[usrRPT0728b]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrRPT0728b_DataTimeStamp]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrRPT0728b_DataTimeStamp] ON [dbo].[usrRPT0728b]
(
	[DataTimeStamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrRPT0728b_xDataIDx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrRPT0728b_xDataIDx] ON [dbo].[usrRPT0728b]
(
	[xDataIDx] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrRPT0728b_xOutputFileNamex]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrRPT0728b_xOutputFileNamex] ON [dbo].[usrRPT0728b]
(
	[xOutputFileNamex] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
