USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[FLT_Travellers]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FLT_Travellers](
	[GroupName] [nvarchar](50) NOT NULL,
	[OutletName] [nvarchar](50) NOT NULL,
	[AlphaCode] [nvarchar](20) NOT NULL,
	[FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[PostingDate] [datetime] NULL,
	[Number Of Travellers] [int] NOT NULL
) ON [PRIMARY]
GO
