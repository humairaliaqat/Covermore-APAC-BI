USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[entSanctionedDOB]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[entSanctionedDOB](
	[Country] [varchar](2) NOT NULL,
	[SanctionID] [varchar](50) NULL,
	[Reference] [varchar](61) NULL,
	[DOBString] [nvarchar](max) NULL,
	[DOB] [date] NULL,
	[MOB] [int] NULL,
	[YOBStart] [bigint] NULL,
	[YOBEnd] [bigint] NULL,
	[InsertionDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
