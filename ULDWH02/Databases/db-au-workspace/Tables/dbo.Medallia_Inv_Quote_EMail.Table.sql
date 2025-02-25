USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Medallia_Inv_Quote_EMail]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Medallia_Inv_Quote_EMail](
	[SessionID] [int] NOT NULL,
	[TITLE] [nvarchar](4000) NULL,
	[FIRSTNAME] [nvarchar](20) NULL,
	[LASTNAME] [nvarchar](20) NULL,
	[EMAILADDRESS] [nvarchar](4000) NULL,
	[Date] [datetime] NOT NULL,
	[CreatedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
