USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sungl_departmentcode_mapping]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sungl_departmentcode_mapping](
	[Old Department Code] [nvarchar](255) NULL,
	[Description] [nvarchar](255) NULL,
	[New Department Code] [float] NULL
) ON [PRIMARY]
GO
