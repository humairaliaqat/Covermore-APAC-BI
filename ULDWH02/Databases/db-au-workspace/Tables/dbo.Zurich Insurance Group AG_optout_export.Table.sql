USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Zurich Insurance Group AG_optout_export]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Zurich Insurance Group AG_optout_export](
	[EmailId] [nvarchar](100) NULL,
	[File_Name] [varchar](500) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
