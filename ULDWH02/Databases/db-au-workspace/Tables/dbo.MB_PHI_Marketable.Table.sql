USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[MB_PHI_Marketable]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MB_PHI_Marketable](
	[ID] [nvarchar](255) NULL,
	[First Name] [nvarchar](255) NULL,
	[Surname] [nvarchar](255) NULL,
	[Postcode] [nvarchar](255) NULL,
	[Email] [nvarchar](255) NULL,
	[Mobile Phone] [nvarchar](255) NULL,
	[Home Phone] [nvarchar](255) NULL,
	[Work Phone] [nvarchar](255) NULL,
	[Marketable_Flag] [nvarchar](255) NULL,
	[CustomerID] [bigint] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [cidx]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE CLUSTERED INDEX [cidx] ON [dbo].[MB_PHI_Marketable]
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
