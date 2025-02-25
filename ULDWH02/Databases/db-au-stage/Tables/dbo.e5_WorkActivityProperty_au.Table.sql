USE [db-au-stage]
GO
/****** Object:  Table [dbo].[e5_WorkActivityProperty_au]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[e5_WorkActivityProperty_au](
	[Work_Id] [uniqueidentifier] NOT NULL,
	[WorkActivity_Id] [uniqueidentifier] NOT NULL,
	[Property_Id] [nvarchar](32) NOT NULL,
	[PropertyValue] [sql_variant] NULL
) ON [PRIMARY]
GO
