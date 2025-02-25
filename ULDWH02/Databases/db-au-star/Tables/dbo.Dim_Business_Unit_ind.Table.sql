USE [db-au-star]
GO
/****** Object:  Table [dbo].[Dim_Business_Unit_ind]    Script Date: 24/02/2025 5:10:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Business_Unit_ind](
	[Business_Unit_SK] [int] IDENTITY(1,1) NOT NULL,
	[Business_Unit_Code] [varchar](50) NOT NULL,
	[Business_Unit_Desc] [varchar](200) NULL,
	[Parent_Business_Unit_SK] [int] NULL,
	[Country_Code] [varchar](50) NOT NULL,
	[Country_Desc] [varchar](200) NULL,
	[Region_Code] [varchar](50) NOT NULL,
	[Region_Desc] [varchar](200) NULL,
	[Type_of_Entity_Code] [varchar](50) NOT NULL,
	[Type_of_Entity_Desc] [varchar](200) NULL,
	[Type_of_Business_Code] [varchar](50) NOT NULL,
	[Type_of_Business_Desc] [varchar](200) NULL,
	[Create_Date] [datetime] NOT NULL,
	[Update_Date] [datetime] NULL,
	[Insert_Batch_ID] [int] NOT NULL,
	[Update_Batch_ID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [Dim_Business_Unit_PK_ind]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE CLUSTERED INDEX [Dim_Business_Unit_PK_ind] ON [dbo].[Dim_Business_Unit_ind]
(
	[Business_Unit_SK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX01_Dim_Business_Unit_ind]    Script Date: 24/02/2025 5:10:01 PM ******/
CREATE NONCLUSTERED INDEX [IX01_Dim_Business_Unit_ind] ON [dbo].[Dim_Business_Unit_ind]
(
	[Business_Unit_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
