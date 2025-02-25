USE [db-au-actuary]
GO
/****** Object:  Table [dbo].[ESM_Claims]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ESM_Claims](
	[claim_no] [varchar](250) NULL,
	[Special_Measure_with_Leakage] [varchar](250) NULL,
	[Special_Measure_Anyway] [varchar](250) NULL,
	[Date] [date] NULL
) ON [PRIMARY]
GO
