USE [db-au-log]
GO
/****** Object:  Table [dbo].[ETL_Source_File]    Script Date: 24/02/2025 2:34:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ETL_Source_File](
	[Source_File_ID] [int] IDENTITY(0,1) NOT NULL,
	[Source_File_Name] [varchar](50) NULL,
	[Subject_Area] [varchar](50) NULL,
	[Staging_Load_Ind] [char](1) NULL,
	[ODS_Load_Ind] [char](1) NULL,
	[DWH_Load_Ind] [char](1) NULL
) ON [PRIMARY]
GO
