USE [db-au-stage]
GO
/****** Object:  Table [dbo].[etl_excel_supergroup]    Script Date: 24/02/2025 5:08:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[etl_excel_supergroup](
	[Country] [nvarchar](255) NULL,
	[DomainID] [int] NULL,
	[SuperGroup] [nvarchar](255) NULL
) ON [PRIMARY]
GO
