USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[e5_profile]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_profile](
	[RowNumber] [int] IDENTITY(0,1) NOT NULL,
	[EventClass] [int] NULL,
	[TextData] [ntext] NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [nvarchar](128) NULL,
	[ObjectID] [int] NULL,
	[ObjectName] [nvarchar](128) NULL,
	[ServerName] [nvarchar](128) NULL,
	[BinaryData] [image] NULL,
	[SPID] [int] NULL,
	[StartTime] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[RowNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
