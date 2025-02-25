USE [db-au-stage]
GO
/****** Object:  Table [dbo].[test_tab]    Script Date: 24/02/2025 5:08:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[test_tab](
	[quotedprice] [numeric](11, 4) NULL,
	[grosspremium] [money] NULL,
	[risknet] [money] NULL
) ON [PRIMARY]
GO
