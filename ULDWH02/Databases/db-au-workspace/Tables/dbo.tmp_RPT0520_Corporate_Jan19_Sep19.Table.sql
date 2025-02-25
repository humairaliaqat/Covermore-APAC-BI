USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_RPT0520_Corporate_Jan19_Sep19]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_RPT0520_Corporate_Jan19_Sep19](
	[Country] [varchar](2) NOT NULL,
	[Company] [varchar](5) NOT NULL,
	[Month Start] [smalldatetime] NULL,
	[Agency Group Code] [nvarchar](50) NOT NULL,
	[Agency State] [nvarchar](100) NULL,
	[Excess] [money] NULL,
	[Underwriter Sale (ex GST)] [money] NULL,
	[GST Gross] [money] NULL,
	[GST CM Commission] [money] NULL,
	[Agency Commission (ex GST)] [money] NULL,
	[Domestic Stamp Duty] [money] NULL,
	[International Stamp Duty] [money] NULL,
	[CM Commission (ex GTST)] [money] NULL,
	[GST Agent Commission] [money] NULL,
	[Domestic Premium (inc GST)] [money] NULL,
	[State] [varchar](20) NULL,
	[Quote ID] [int] NOT NULL,
	[Policy Number] [int] NULL,
	[Issued Date] [datetime] NULL,
	[Underwriter] [varchar](10) NOT NULL,
	[Product Code] [varchar](3) NOT NULL,
	[Policy Start Date] [datetime] NULL,
	[Policy Expiry Date] [datetime] NULL,
	[Calculated International Stamp Duty] [decimal](38, 9) NULL,
	[Calculated Domestic Stamp Duty] [decimal](38, 9) NULL,
	[JV Code] [nvarchar](50) NULL,
	[JV Description] [nvarchar](200) NULL,
	[Channel] [nvarchar](100) NULL,
	[Agency Sub Group Name] [nvarchar](50) NULL,
	[Agency Sub Group Code] [nvarchar](50) NULL,
	[Policy Count] [int] NULL
) ON [PRIMARY]
GO
