USE [db-au-star]
GO
/****** Object:  Table [dbo].[Dim_Department_ind]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Department_ind](
	[Department_SK] [int] IDENTITY(1,1) NOT NULL,
	[Department_Code] [varchar](50) NOT NULL,
	[Department_Desc] [varchar](200) NULL,
	[Parent_Department_Code] [varchar](50) NOT NULL,
	[Parent_Department_Desc] [varchar](200) NULL,
	[Department_Type_Code] [varchar](50) NOT NULL,
	[Department_Type_Desc] [varchar](200) NULL,
	[Department_Entity_Code] [varchar](50) NOT NULL,
	[Department_Entity_Desc] [varchar](200) NULL,
	[Create_Date] [datetime] NOT NULL,
	[Update_Date] [datetime] NULL,
	[Insert_Batch_ID] [int] NOT NULL,
	[Update_Batch_ID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [Dim_Department_PK_ind]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED INDEX [Dim_Department_PK_ind] ON [dbo].[Dim_Department_ind]
(
	[Department_SK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX01_Dim_Department_ind]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [IX01_Dim_Department_ind] ON [dbo].[Dim_Department_ind]
(
	[Department_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
