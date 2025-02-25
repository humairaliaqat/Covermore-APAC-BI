USE [db-au-stage]
GO
/****** Object:  Table [dbo].[STG_Channel]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[STG_Channel](
	[Type_of_Channel_Code] [varchar](50) NOT NULL,
	[Type_of_Channel_Desc] [varchar](200) NULL,
	[Channel_Code] [varchar](50) NOT NULL,
	[Channel_Desc] [varchar](200) NULL,
	[Last_Change_Timestamp] [datetime] NOT NULL
) ON [PRIMARY]
GO
