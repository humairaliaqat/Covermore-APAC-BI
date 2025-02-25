USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[test_processor]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[test_processor](
	[SourceTable] [int] NOT NULL,
	[DataKey] [varchar](40) NULL,
	[AddressLine] [nvarchar](100) NULL,
	[Suburb] [nvarchar](50) NULL,
	[State] [nvarchar](100) NULL,
	[PostCode] [nvarchar](50) NULL,
	[Country] [nvarchar](100) NULL,
	[Domain] [varchar](2) NOT NULL,
	[Processed] [int] NOT NULL
) ON [PRIMARY]
GO
