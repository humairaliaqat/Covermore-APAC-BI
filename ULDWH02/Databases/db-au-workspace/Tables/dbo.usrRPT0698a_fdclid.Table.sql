USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[usrRPT0698a_fdclid]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrRPT0698a_fdclid](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[xOutputFileNamex] [varchar](64) NULL,
	[xDataIDx] [varchar](41) NULL,
	[xDataValuex] [money] NOT NULL,
	[Data] [nvarchar](max) NULL,
	[xFailx] [bit] NOT NULL,
	[DataTimeStamp] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [idx_usrRPT0698a_fdclid_BIRowID]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE CLUSTERED INDEX [idx_usrRPT0698a_fdclid_BIRowID] ON [dbo].[usrRPT0698a_fdclid]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrRPT0698a_fdclid_DataTimeStamp]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrRPT0698a_fdclid_DataTimeStamp] ON [dbo].[usrRPT0698a_fdclid]
(
	[DataTimeStamp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrRPT0698a_fdclid_xDataIDx]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrRPT0698a_fdclid_xDataIDx] ON [dbo].[usrRPT0698a_fdclid]
(
	[xDataIDx] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrRPT0698a_fdclid_xOutputFileNamex]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrRPT0698a_fdclid_xOutputFileNamex] ON [dbo].[usrRPT0698a_fdclid]
(
	[xOutputFileNamex] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
