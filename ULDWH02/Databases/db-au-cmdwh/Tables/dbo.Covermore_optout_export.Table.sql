USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Covermore_optout_export]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Covermore_optout_export](
	[EmailId] [nvarchar](100) NULL,
	[File_Name] [varchar](500) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY]
GO
