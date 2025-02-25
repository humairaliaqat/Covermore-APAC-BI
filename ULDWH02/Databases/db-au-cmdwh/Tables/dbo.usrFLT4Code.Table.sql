USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrFLT4Code]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrFLT4Code](
	[EMP_T4_CODE] [nvarchar](255) NULL,
	[PERSON_NAME] [nvarchar](255) NULL,
	[EMP_EMAIL] [nvarchar](255) NULL,
	[JOB_TITLE] [nvarchar](255) NULL,
	[DIVISION_NAME] [nvarchar](255) NULL,
	[COUNTRY_NAME] [nvarchar](255) NULL,
	[BUSTYPE_NAME] [nvarchar](255) NULL,
	[SHOP_NAME] [nvarchar](255) NULL,
	[SHOP] [nvarchar](255) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE CLUSTERED INDEX [idx] ON [dbo].[usrFLT4Code]
(
	[EMP_T4_CODE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
