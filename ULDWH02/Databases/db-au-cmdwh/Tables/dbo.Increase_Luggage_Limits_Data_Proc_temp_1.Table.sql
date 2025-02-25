USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Increase_Luggage_Limits_Data_Proc_temp_1]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Increase_Luggage_Limits_Data_Proc_temp_1](
	[Policy_Number] [varchar](5000) NULL,
	[Transaction Type] [varchar](1000) NULL,
	[Transaction_Sequence_Number] [varchar](1000) NULL,
	[Transaction_Status] [varchar](1000) NULL,
	[Transaction_Date] [varchar](5000) NULL,
	[Sold_Date] [varchar](5000) NULL,
	[Rate_Effective_Date] [varchar](1000) NULL,
	[Traveller_Sequence_No] [varchar](1000) NULL,
	[Item_Description] [varchar](1000) NULL,
	[Item_Limit_Increase_Amount] [varchar](1000) NULL
) ON [PRIMARY]
GO
