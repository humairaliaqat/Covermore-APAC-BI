USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[ROFI_20181021]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ROFI_20181021](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[CustomerID] [bigint] NULL,
	[PolicyKey] [varchar](50) NULL,
	[SURNAME] [varchar](50) NULL,
	[GIVEN] [varchar](50) NULL,
	[DOB] [date] NULL,
	[ADDRESS] [varchar](250) NULL,
	[EMAIL] [varchar](250) NULL,
	[CLAIM] [varchar](50) NULL,
	[POLICY] [varchar](50) NULL,
	[FRAUD] [varchar](50) NULL,
	[REASON] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
