USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[entSanctionedDOB_Temp]    Script Date: 24/02/2025 5:22:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[entSanctionedDOB_Temp](
	[Country] [varchar](50) NULL,
	[SanctionID] [varchar](50) NULL,
	[Reference] [varchar](50) NULL,
	[DOBString] [varchar](250) NULL,
	[DOB] [varchar](50) NULL,
	[MOB] [varchar](50) NULL,
	[YOBStart] [varchar](50) NULL,
	[YOBEnd] [varchar](50) NULL,
	[Insertion_Date] [date] NULL
) ON [PRIMARY]
GO
