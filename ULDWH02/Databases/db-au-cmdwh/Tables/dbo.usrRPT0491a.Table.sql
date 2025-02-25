USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrRPT0491a]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrRPT0491a](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[xOutputFileNamex] [varchar](64) NULL,
	[xDataIDx] [varchar](41) NULL,
	[xDataValuex] [money] NOT NULL,
	[Data] [nvarchar](max) NULL,
	[xFailx] [bit] NOT NULL,
	[DataTimeStamp] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[usrRPT0491a] ADD  DEFAULT ((0)) FOR [xDataValuex]
GO
ALTER TABLE [dbo].[usrRPT0491a] ADD  DEFAULT ((0)) FOR [xFailx]
GO
ALTER TABLE [dbo].[usrRPT0491a] ADD  DEFAULT (getdate()) FOR [DataTimeStamp]
GO
