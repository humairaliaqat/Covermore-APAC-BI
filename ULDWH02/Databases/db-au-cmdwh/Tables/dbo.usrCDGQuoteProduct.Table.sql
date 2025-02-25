USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrCDGQuoteProduct]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrCDGQuoteProduct](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NULL,
	[ProductKey] [nvarchar](100) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[usrCDGQuoteProduct]
(
	[ProductID] ASC
)
INCLUDE([ProductKey]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
