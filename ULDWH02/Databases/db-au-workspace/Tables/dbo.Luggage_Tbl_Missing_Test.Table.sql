USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Luggage_Tbl_Missing_Test]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Luggage_Tbl_Missing_Test](
	[Policy_Number] [varchar](50) NULL,
	[Transaction_Sequence_Number] [varchar](41) NULL,
	[Transaction_Status] [nvarchar](50) NULL,
	[Transaction_Date] [varchar](50) NULL,
	[Sold_Date] [varchar](50) NULL,
	[Rate_Effective_Date] [varchar](50) NULL,
	[Traveller_Sequence_No] [bigint] NULL,
	[Transaction Type] [varchar](50) NULL,
	[Item_Description] [nvarchar](500) NULL,
	[Item_Limit_Increase_Amount] [money] NULL
) ON [PRIMARY]
GO
