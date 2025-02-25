USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[cdgquote2]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdgquote2](
	[QuoteDate] [date] NULL,
	[QuoteCount] [int] NULL,
	[QuoteSessionCount] [int] NULL,
	[Domain] [nvarchar](2) NOT NULL,
	[BusinessUnit] [varchar](100) NOT NULL
) ON [PRIMARY]
GO
