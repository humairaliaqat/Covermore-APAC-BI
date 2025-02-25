USE [db-au-stage]
GO
/****** Object:  Table [dbo].[Temp_Plandrop]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Temp_Plandrop](
	[Lead_Number] [int] NOT NULL,
	[GCLID] [varchar](500) NOT NULL,
	[GA_Client_ID] [varchar](500) NOT NULL,
	[Link_ID] [varchar](500) NULL,
	[Session ID] [int] NOT NULL,
	[Age] [varchar](500) NULL,
	[Destination] [nvarchar](max) NULL,
	[Region_List] [nvarchar](4000) NULL,
	[Quote Date] [date] NULL,
	[Trip Start] [date] NULL,
	[Trip end] [date] NULL,
	[Promotional_Factor] [varchar](500) NOT NULL,
	[Excess] [decimal](10, 4) NULL,
	[Plan Type] [nvarchar](100) NULL,
	[Trip Type] [varchar](1) NOT NULL,
	[Premium] [decimal](10, 4) NULL,
	[Agency_Code] [varchar](100) NULL,
	[Agency_Name] [nvarchar](50) NULL,
	[Brand] [nvarchar](50) NULL,
	[Channel_Type] [varchar](6) NOT NULL,
	[Session_Token] [varchar](150) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
