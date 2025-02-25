USE [db-au-star]
GO
/****** Object:  Table [dbo].[Dim_CCATeams_Codes]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_CCATeams_Codes](
	[CCATeams_Codes_SK] [int] IDENTITY(1,1) NOT NULL,
	[CCATeams_Code] [varchar](50) NOT NULL,
	[CCATeams_Desc] [varchar](200) NULL,
	[CCATeams_Owner_Code] [varchar](50) NOT NULL,
	[CCATeams_Owner_Desc] [varchar](200) NULL,
	[Parent_CCATeams_Code] [varchar](50) NOT NULL,
	[Parent_CCATeams_Code_Desc] [varchar](200) NULL,
	[Create_Date] [datetime] NOT NULL,
	[Update_Date] [datetime] NULL,
	[Insert_Batch_ID] [int] NOT NULL,
	[Update_Batch_ID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [Dim_CCATeams_Codes_PK]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED INDEX [Dim_CCATeams_Codes_PK] ON [dbo].[Dim_CCATeams_Codes]
(
	[CCATeams_Codes_SK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX01_Dim_CCATeams_Codes]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [IX01_Dim_CCATeams_Codes] ON [dbo].[Dim_CCATeams_Codes]
(
	[CCATeams_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
