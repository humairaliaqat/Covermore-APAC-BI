USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_Channel_AU]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_Channel_AU](
	[ChannelId] [int] NOT NULL,
	[Channel] [nvarchar](255) NULL,
	[Currency] [char](3) NULL
) ON [PRIMARY]
GO
