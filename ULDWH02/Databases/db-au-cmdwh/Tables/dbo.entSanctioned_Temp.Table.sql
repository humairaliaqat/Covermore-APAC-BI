USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[entSanctioned_Temp]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[entSanctioned_Temp](
	[Country] [varchar](50) NULL,
	[SanctionID] [varchar](50) NULL,
	[Reference] [varchar](50) NULL,
	[Name] [nvarchar](500) NULL,
	[DOBString] [varchar](250) NULL,
	[Control Date] [varchar](50) NULL,
	[Insertion_Date] [date] NULL
) ON [PRIMARY]
GO
