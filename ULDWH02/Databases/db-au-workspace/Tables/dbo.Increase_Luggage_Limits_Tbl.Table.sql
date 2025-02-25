USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Increase_Luggage_Limits_Tbl]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Increase_Luggage_Limits_Tbl](
	[Policy_Number] [varchar](50) NOT NULL,
	[Transaction Type] [varchar](50) NOT NULL,
	[Transaction_Sequence_Number] [varchar](41) NOT NULL,
	[Transaction_Status] [nvarchar](50) NOT NULL,
	[Transaction_Date] [varchar](50) NOT NULL,
	[Sold_Date] [varchar](50) NOT NULL,
	[Rate_Effective_Date] [varchar](50) NOT NULL,
	[Traveller_Sequence_No] [bigint] NOT NULL,
	[Item_Description] [nvarchar](500) NOT NULL,
	[Item_Limit_Increase_Amount] [money] NOT NULL
) ON [PRIMARY]
GO
