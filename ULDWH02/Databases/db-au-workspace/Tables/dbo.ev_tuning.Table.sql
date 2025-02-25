USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ev_tuning]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ev_tuning](
	[RowNumber] [int] IDENTITY(0,1) NOT NULL,
	[EventClass] [int] NULL,
	[Duration] [bigint] NULL,
	[TextData] [ntext] NULL,
	[SPID] [int] NULL,
	[BinaryData] [image] NULL,
	[ApplicationName] [nvarchar](128) NULL,
	[StartTime] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[RowNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
