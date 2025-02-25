USE [db-au-stage]
GO
/****** Object:  Table [dbo].[sungl_excel_product]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sungl_excel_product](
	[Product Parent Code] [nvarchar](255) NULL,
	[Product Parent Description] [nvarchar](255) NULL,
	[Product Type Code] [nvarchar](255) NULL,
	[Product Type Description] [nvarchar](255) NULL,
	[Product Code] [nvarchar](255) NULL,
	[Product Description] [nvarchar](255) NULL
) ON [PRIMARY]
GO
