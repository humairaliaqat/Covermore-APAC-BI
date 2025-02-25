USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ROFI_20181022]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ROFI_20181022](
	[SURNAME] [nvarchar](255) NULL,
	[GIVEN] [nvarchar](255) NULL,
	[DOB] [datetime] NULL,
	[ADDRESS] [nvarchar](255) NULL,
	[E-MAIL] [nvarchar](255) NULL,
	[CLAIM] [float] NULL,
	[POLICY] [float] NULL,
	[FRAUD] [nvarchar](255) NULL,
	[REASON] [nvarchar](255) NULL
) ON [PRIMARY]
GO
