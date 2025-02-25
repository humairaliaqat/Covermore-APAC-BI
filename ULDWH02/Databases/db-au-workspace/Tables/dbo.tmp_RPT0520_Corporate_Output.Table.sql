USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_RPT0520_Corporate_Output]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_RPT0520_Corporate_Output](
	[Country] [varchar](2) NOT NULL,
	[Company] [varchar](5) NOT NULL,
	[Underwriter] [varchar](10) NOT NULL,
	[Month Start] [smalldatetime] NULL,
	[Issued Date] [datetime] NULL,
	[JV Code] [nvarchar](50) NULL,
	[Group Code] [nvarchar](50) NOT NULL,
	[Sub Group Code] [nvarchar](50) NULL,
	[Sub Group Name] [nvarchar](50) NULL,
	[Agency State] [nvarchar](100) NULL,
	[Channel] [nvarchar](100) NULL,
	[Policy Number] [int] NULL,
	[Policy Start Date] [datetime] NULL,
	[Policy Expiry Date] [datetime] NULL,
	[State] [varchar](20) NULL,
	[Excess] [money] NULL,
	[Agency Comm (excl GST)] [money] NULL,
	[GST on Agent Comm] [money] NULL,
	[Domestic Sell Price (excl GST)] [money] NULL,
	[International Sell Price (excl GST)] [money] NULL,
	[Domestic Premium] [money] NULL,
	[International Premium] [money] NULL,
	[Total Premium] [money] NULL,
	[Sell Price (excl GST)] [money] NULL,
	[GST on Sell Price] [money] NULL,
	[Stamp Duty on Domestic Sell Price] [money] NULL,
	[Stamp Duty on International Sell Price] [money] NULL,
	[Stamp Duty on Sell Price] [money] NULL,
	[Recalculated Domestic Stamp Duty] [decimal](38, 9) NULL,
	[Recalculated International Stamp Duty] [decimal](38, 9) NULL
) ON [PRIMARY]
GO
