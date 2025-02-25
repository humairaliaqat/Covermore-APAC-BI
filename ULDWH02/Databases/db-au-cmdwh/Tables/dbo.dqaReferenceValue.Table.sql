USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[dqaReferenceValue]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dqaReferenceValue](
	[id] [int] IDENTITY(0,1) NOT NULL,
	[CountryKey] [char](2) NULL,
	[refEntity] [varchar](50) NULL,
	[refValue] [varchar](255) NULL,
	[isEnabled] [bit] NULL,
	[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
