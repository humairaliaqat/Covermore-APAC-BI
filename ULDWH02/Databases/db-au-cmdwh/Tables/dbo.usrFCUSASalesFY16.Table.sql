USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrFCUSASalesFY16]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrFCUSASalesFY16](
	[T3] [nvarchar](20) NULL,
	[Store] [nvarchar](200) NULL,
	[Brand] [nvarchar](100) NULL,
	[GrossPremium] [money] NOT NULL,
	[PolicyCount] [float] NOT NULL,
	[FMonth] [datetime] NULL,
	[AlphaCode] [nvarchar](20) NULL,
	[OutletName] [nvarchar](50) NULL,
	[FCNation] [nvarchar](50) NULL,
	[FCArea] [nvarchar](50) NULL
) ON [PRIMARY]
GO
