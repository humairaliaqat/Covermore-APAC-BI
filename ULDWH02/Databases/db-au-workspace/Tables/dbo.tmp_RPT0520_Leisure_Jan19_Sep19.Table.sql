USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[tmp_RPT0520_Leisure_Jan19_Sep19]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmp_RPT0520_Leisure_Jan19_Sep19](
	[Country] [varchar](2) NOT NULL,
	[Company] [varchar](5) NOT NULL,
	[Underwriter] [varchar](10) NOT NULL,
	[Issue Date] [date] NOT NULL,
	[Posting Date] [datetime] NULL,
	[Agency Group Code] [nvarchar](50) NOT NULL,
	[Agency State] [nvarchar](100) NULL,
	[Product Code] [nvarchar](50) NULL,
	[JV Code] [nvarchar](50) NULL,
	[JV Description] [nvarchar](200) NULL,
	[Excess] [money] NOT NULL,
	[Destination] [nvarchar](max) NULL,
	[Departure Date] [datetime] NULL,
	[Return Date] [datetime] NULL,
	[Policy Number] [varchar](50) NULL,
	[Agency Code] [nvarchar](20) NOT NULL,
	[Area No] [varchar](20) NULL,
	[Area Type] [varchar](25) NULL,
	[Parent Policy Number] [varchar](50) NULL,
	[Transaction Type] [varchar](50) NULL,
	[Transaction Status] [nvarchar](50) NULL,
	[Trip Type] [nvarchar](50) NULL,
	[Plan Code] [nvarchar](4000) NULL,
	[Plan] [nvarchar](100) NULL,
	[Single Family] [varchar](9) NOT NULL,
	[Cancellation Cover] [nvarchar](50) NULL,
	[Commission Tier] [varchar](50) NULL,
	[Finance Product Code] [nvarchar](10) NULL,
	[Finance Old Product Code] [nvarchar](50) NULL,
	[State] [nvarchar](100) NULL,
	[Age] [int] NULL,
	[New Policy Count] [int] NULL,
	[Unadjusted Sell Price] [money] NULL,
	[Unadjusted GST on Sell Price] [money] NULL,
	[Sell Price] [money] NULL,
	[Sell Price (excl GST)] [money] NULL,
	[GST on Sell Price] [money] NULL,
	[Stampt Duty on Sell Price] [money] NULL,
	[Premium] [money] NULL,
	[Agency Commission] [money] NULL,
	[GST on Agency Commission] [money] NULL,
	[Stamp Duty on Agency Commission] [money] NULL,
	[NAP] [money] NULL,
	[NAP (incl Tax)] [money] NULL,
	[Risk Nett] [money] NULL,
	[Pricing Exposure Measure] [numeric](38, 8) NULL,
	[Gross Up] [numeric](38, 8) NULL,
	[Number of Adults Count] [int] NULL,
	[Number of Children Count] [int] NULL,
	[Base Premium] [money] NULL,
	[Medical Gross Premium] [money] NULL,
	[Luggage Gross Premium] [money] NULL,
	[Rental Car Gross Premium] [money] NULL,
	[Motorcycle Gross Premium] [money] NULL,
	[Winter Sport Gross Premium] [money] NULL,
	[Cancellation Gross Premium] [money] NULL,
	[Recalculated GST] [numeric](38, 5) NULL,
	[Recalculated Stamp Duty] [numeric](38, 6) NULL,
	[Unadjusted Agency Commission] [money] NULL,
	[UW Rate] [numeric](38, 6) NULL,
	[Channel] [nvarchar](100) NULL,
	[Agency Sub Group Name] [nvarchar](50) NULL,
	[Agency Sub Group Code] [nvarchar](50) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_RPT0520_Leisure_PolicyNumber]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE CLUSTERED INDEX [idx_RPT0520_Leisure_PolicyNumber] ON [dbo].[tmp_RPT0520_Leisure_Jan19_Sep19]
(
	[Policy Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_RPT0520_Leisure_PostingDate]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_RPT0520_Leisure_PostingDate] ON [dbo].[tmp_RPT0520_Leisure_Jan19_Sep19]
(
	[Posting Date] ASC
)
INCLUDE([Country],[Company],[Underwriter]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
