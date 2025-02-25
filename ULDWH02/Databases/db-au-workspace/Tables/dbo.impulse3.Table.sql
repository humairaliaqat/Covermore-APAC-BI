USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[impulse3]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[impulse3](
	[BusinessUnit] [nvarchar](255) NULL,
	[Date] [smalldatetime] NOT NULL,
	[QuoteSessionCount] [int] NULL,
	[OfferSessionCount] [int] NULL,
	[SessionCount] [int] NULL,
	[OldQuoteCount] [int] NULL
) ON [PRIMARY]
GO
