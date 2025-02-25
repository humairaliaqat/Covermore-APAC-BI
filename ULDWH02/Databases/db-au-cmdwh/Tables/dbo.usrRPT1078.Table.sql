USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrRPT1078]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrRPT1078](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[xOutputFileNamex] [varchar](64) NULL,
	[xDataIDx] [varchar](41) NULL,
	[xDataValuex] [money] NULL,
	[Data] [nvarchar](max) NULL,
	[xFailx] [bit] NOT NULL,
	[DataTimeStamp] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
