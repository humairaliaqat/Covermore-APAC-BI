USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_excel_channel]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_excel_channel](
	[ChannelID] [float] NULL,
	[Channel] [nvarchar](255) NULL
) ON [PRIMARY]
GO
