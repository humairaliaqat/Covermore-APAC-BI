USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[CustomerAddress_v4]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerAddress_v4](
	[CustomerID] [bigint] NOT NULL,
	[CurrentAddress] [nvarchar](614) NULL
) ON [PRIMARY]
GO
