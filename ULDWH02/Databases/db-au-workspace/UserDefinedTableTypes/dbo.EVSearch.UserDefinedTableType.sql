USE [db-au-workspace]
GO
/****** Object:  UserDefinedTableType [dbo].[EVSearch]    Script Date: 24/02/2025 5:22:15 PM ******/
CREATE TYPE [dbo].[EVSearch] AS TABLE(
	[CustomerID] [bigint] NULL,
	[ForceInclude] [bit] NULL
)
GO
