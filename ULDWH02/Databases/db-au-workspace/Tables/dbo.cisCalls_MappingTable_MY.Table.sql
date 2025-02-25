USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[cisCalls_MappingTable_MY]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cisCalls_MappingTable_MY](
	[ApplicationName] [varchar](19) NOT NULL,
	[GatewayNumber] [nvarchar](30) NULL,
	[Group] [varchar](250) NULL
) ON [PRIMARY]
GO
