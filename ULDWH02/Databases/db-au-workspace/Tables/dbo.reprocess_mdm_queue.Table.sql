USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[reprocess_mdm_queue]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[reprocess_mdm_queue](
	[CustomerName] [nvarchar](255) NULL,
	[DOB] [date] NOT NULL,
	[RecCount] [int] NULL,
	[PolicyCount] [int] NULL
) ON [PRIMARY]
GO
