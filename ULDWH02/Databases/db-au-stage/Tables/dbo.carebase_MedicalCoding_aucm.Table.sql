USE [db-au-stage]
GO
/****** Object:  Table [dbo].[carebase_MedicalCoding_aucm]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[carebase_MedicalCoding_aucm](
	[Id] [int] NOT NULL,
	[CASE_NO] [varchar](14) NOT NULL,
	[RawOutput] [nvarchar](max) NULL,
	[CreatedBy] [varchar](30) NOT NULL,
	[CreatedTime] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
