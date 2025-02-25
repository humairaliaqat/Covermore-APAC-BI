USE [db-au-actuary]
GO
/****** Object:  Table [cng].[Policy_Header]    Script Date: 21/02/2025 11:15:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [cng].[Policy_Header](
	[BIRowID] [bigint] NOT NULL,
	[Domain Country] [varchar](2) NULL,
	[Company] [varchar](5) NULL,
	[PolicyKey] [varchar](41) NULL,
	[Base Policy No] [varchar](50) NULL,
	[Policy Status] [varchar](50) NULL,
	[Issue Date] [datetime] NULL,
	[Posting Date] [datetime] NULL,
	[Last Transaction Issue Date] [datetime] NULL,
	[Last Transaction Posting Date] [datetime] NULL,
	[Transaction Type] [varchar](50) NULL,
	[Departure Date] [datetime] NULL,
	[Return Date] [datetime] NULL,
	[Lead Time] [int] NULL,
	[Trip Duration] [int] NULL,
	[Trip Length] [int] NULL,
	[Maximum Trip Length] [int] NULL,
	[Area Name] [nvarchar](150) NULL,
	[Area Number] [varchar](20) NULL,
	[Area] [nvarchar](100) NULL,
	[AreaCode] [nvarchar](3) NULL,
	[Destination] [nvarchar](max) NULL,
	[Multi Destination] [nvarchar](max) NULL,
	[Excess] [int] NULL,
	[Group Policy] [int] NULL,
	[Has Rental Car] [bit] NULL,
	[Has Motorcycle] [bit] NULL,
	[Has Wintersport] [bit] NULL,
	[Has Medical] [bit] NULL,
	[Single/Family] [nvarchar](1) NULL,
	[Purchase Path] [nvarchar](50) NULL,
	[TRIPS Policy] [bit] NULL,
	[Product Code] [nvarchar](50) NULL,
	[Plan Code] [nvarchar](50) NULL,
	[Product Name] [nvarchar](100) NULL,
	[Product Plan] [nvarchar](100) NULL,
	[Product Type] [nvarchar](100) NULL,
	[Product Group] [nvarchar](100) NULL,
	[Policy Type] [nvarchar](50) NULL,
	[Plan Type] [nvarchar](50) NULL,
	[Trip Type] [nvarchar](50) NULL,
	[Product Classification] [nvarchar](100) NULL,
	[Finance Product Code] [nvarchar](50) NULL,
	[OutletKey] [varchar](33) NULL,
	[Alpha Code] [nvarchar](20) NULL,
	[Latest OutletKey] [varchar](33) NULL,
	[Latest Alpha Code] [nvarchar](max) NULL,
	[Customer Post Code] [nvarchar](50) NULL,
	[Unique Traveller Count] [int] NULL,
	[Unique Charged Traveller Count] [int] NULL,
	[Traveller Count] [int] NULL,
	[Charged Traveller Count] [int] NULL,
	[Adult Traveller Count] [int] NULL,
	[EMC Traveller Count] [int] NULL,
	[Youngest Charged DOB] [datetime] NULL,
	[Oldest Charged DOB] [datetime] NULL,
	[Youngest Age] [int] NULL,
	[Oldest Age] [int] NULL,
	[Youngest Charged Age] [int] NULL,
	[Oldest Charged Age] [int] NULL,
	[Max EMC Score] [numeric](18, 2) NULL,
	[Total EMC Score] [numeric](18, 2) NULL,
	[Gender] [varchar](2) NULL,
	[Has EMC] [varchar](1) NULL,
	[Has Manual EMC] [varchar](1) NULL,
	[Charged Traveller 1 Gender] [nchar](2) NULL,
	[Charged Traveller 1 DOB] [date] NULL,
	[Charged Traveller 1 Has EMC] [smallint] NULL,
	[Charged Traveller 1 Has Manual EMC] [bit] NULL,
	[Charged Traveller 1 EMC Score] [decimal](18, 2) NULL,
	[Charged Traveller 1 EMC Reference] [int] NULL,
	[Charged Traveller 2 Gender] [nchar](2) NULL,
	[Charged Traveller 2 DOB] [date] NULL,
	[Charged Traveller 2 Has EMC] [smallint] NULL,
	[Charged Traveller 2 Has Manual EMC] [bit] NULL,
	[Charged Traveller 2 EMC Score] [decimal](18, 2) NULL,
	[Charged Traveller 2 EMC Reference] [int] NULL,
	[Charged Traveller 3 Gender] [nchar](2) NULL,
	[Charged Traveller 3 DOB] [date] NULL,
	[Charged Traveller 3 Has EMC] [smallint] NULL,
	[Charged Traveller 3 Has Manual EMC] [bit] NULL,
	[Charged Traveller 3 EMC Score] [decimal](18, 2) NULL,
	[Charged Traveller 3 EMC Reference] [int] NULL,
	[Charged Traveller 4 Gender] [nchar](2) NULL,
	[Charged Traveller 4 DOB] [date] NULL,
	[Charged Traveller 4 Has EMC] [smallint] NULL,
	[Charged Traveller 4 Has Manual EMC] [bit] NULL,
	[Charged Traveller 4 EMC Score] [decimal](18, 2) NULL,
	[Charged Traveller 4 EMC Reference] [int] NULL,
	[Charged Traveller 5 Gender] [nchar](2) NULL,
	[Charged Traveller 5 DOB] [date] NULL,
	[Charged Traveller 5 Has EMC] [smallint] NULL,
	[Charged Traveller 5 Has Manual EMC] [bit] NULL,
	[Charged Traveller 5 EMC Score] [decimal](18, 2) NULL,
	[Charged Traveller 5 EMC Reference] [int] NULL,
	[Charged Traveller 6 Gender] [nchar](2) NULL,
	[Charged Traveller 6 DOB] [date] NULL,
	[Charged Traveller 6 Has EMC] [smallint] NULL,
	[Charged Traveller 6 Has Manual EMC] [bit] NULL,
	[Charged Traveller 6 EMC Score] [decimal](18, 2) NULL,
	[Charged Traveller 6 EMC Reference] [int] NULL,
	[Charged Traveller 7 Gender] [nchar](2) NULL,
	[Charged Traveller 7 DOB] [date] NULL,
	[Charged Traveller 7 Has EMC] [smallint] NULL,
	[Charged Traveller 7 Has Manual EMC] [bit] NULL,
	[Charged Traveller 7 EMC Score] [decimal](18, 2) NULL,
	[Charged Traveller 7 EMC Reference] [int] NULL,
	[Charged Traveller 8 Gender] [nchar](2) NULL,
	[Charged Traveller 8 DOB] [date] NULL,
	[Charged Traveller 8 Has EMC] [smallint] NULL,
	[Charged Traveller 8 Has Manual EMC] [bit] NULL,
	[Charged Traveller 8 EMC Score] [decimal](18, 2) NULL,
	[Charged Traveller 8 EMC Reference] [int] NULL,
	[Charged Traveller 9 Gender] [nchar](2) NULL,
	[Charged Traveller 9 DOB] [date] NULL,
	[Charged Traveller 9 Has EMC] [smallint] NULL,
	[Charged Traveller 9 Has Manual EMC] [bit] NULL,
	[Charged Traveller 9 EMC Score] [decimal](18, 2) NULL,
	[Charged Traveller 9 EMC Reference] [int] NULL,
	[Charged Traveller 10 Gender] [nchar](2) NULL,
	[Charged Traveller 10 DOB] [date] NULL,
	[Charged Traveller 10 Has EMC] [smallint] NULL,
	[Charged Traveller 10 Has Manual EMC] [bit] NULL,
	[Charged Traveller 10 EMC Score] [decimal](18, 2) NULL,
	[Charged Traveller 10 EMC Reference] [int] NULL,
	[Commission Tier] [varchar](50) NULL,
	[Volume Commission] [money] NULL,
	[Discount] [money] NULL,
	[Base Base Premium] [money] NULL,
	[Base Premium] [money] NULL,
	[Canx Premium] [money] NULL,
	[Undiscounted Canx Premium] [money] NULL,
	[Rental Car Premium] [money] NULL,
	[Motorcycle Premium] [money] NULL,
	[Luggage Premium] [money] NULL,
	[Medical Premium] [money] NULL,
	[Winter Sport Premium] [money] NULL,
	[Luggage Increase] [money] NULL,
	[Trip Cost] [int] NULL,
	[Unadjusted Sell Price] [money] NULL,
	[Unadjusted GST on Sell Price] [money] NULL,
	[Unadjusted Stamp Duty on Sell Price] [money] NULL,
	[Unadjusted Agency Commission] [money] NULL,
	[Unadjusted GST on Agency Commission] [money] NULL,
	[Unadjusted Stamp Duty on Agency Commission] [money] NULL,
	[Unadjusted Admin Fee] [money] NULL,
	[Sell Price] [float] NULL,
	[GST on Sell Price] [float] NULL,
	[Stamp Duty on Sell Price] [float] NULL,
	[Premium] [float] NULL,
	[Risk Nett] [money] NULL,
	[GUG] [money] NULL,
	[Agency Commission] [money] NULL,
	[GST on Agency Commission] [money] NULL,
	[Stamp Duty on Agency Commission] [money] NULL,
	[Admin Fee] [money] NULL,
	[NAP] [money] NULL,
	[NAP (incl Tax)] [money] NULL,
	[Policy Count] [int] NULL,
	[Price Beat Policy] [bit] NULL,
	[Competitor Name] [nvarchar](50) NULL,
	[Competitor Price] [money] NULL,
	[Category] [varchar](100) NULL,
	[Rental Car Increase] [money] NULL,
	[PolicyID] [nvarchar](102) NULL,
	[EMC Tier Oldest Charged] [int] NULL,
	[EMC Tier Youngest Charged] [int] NULL,
	[Has Cruise] [bit] NULL,
	[Cruise Premium] [money] NULL,
	[Plan Name] [nvarchar](100) NULL,
	[Has COVID19] [int] NOT NULL,
	[Has Pre-Trip] [int] NOT NULL,
	[Has COVID19 Cruise] [int] NOT NULL,
	[Country or Area] [nvarchar](255) NULL,
	[Intermediate Region Name] [nvarchar](255) NULL,
	[Region Name] [nvarchar](255) NULL,
	[Customer State] [nvarchar](255) NULL,
	[UW Policy Status] [nvarchar](50) NULL,
	[UW Premium] [float] NULL,
	[UW Premium COVID19] [float] NULL,
	[UW Domain Country] [nvarchar](50) NULL,
	[UW Issue Month] [datetime2](7) NULL,
	[UW Rating Group] [nvarchar](50) NULL,
	[UW JV Description Orig] [nvarchar](50) NULL,
	[UW JV Group] [nvarchar](50) NULL,
	[UW Product Code] [nvarchar](50) NULL,
	[GLM Freq MED] [float] NULL,
	[GLM Freq CAN] [float] NULL,
	[GLM Freq ADD] [float] NULL,
	[GLM Freq LUG] [float] NULL,
	[GLM Freq MIS] [float] NULL,
	[GLM Freq UDL] [float] NULL,
	[GLM Size MED] [float] NULL,
	[GLM Size LGE] [float] NULL,
	[GLM Size CAN] [float] NULL,
	[GLM Size ADD] [float] NULL,
	[GLM Size LUG] [float] NULL,
	[GLM Size MIS] [float] NULL,
	[GLM Size ULD] [float] NULL,
	[GLM CPP MED] [float] NULL,
	[GLM CPP LGE] [float] NULL,
	[GLM CPP CAN] [float] NULL,
	[GLM CPP ADD] [float] NULL,
	[GLM CPP LUG] [float] NULL,
	[GLM CPP MIS] [float] NULL,
	[GLM CPP UDL] [float] NULL,
	[GLM CPP CAT] [float] NULL,
	[GLM CPP] [float] NULL,
	[GLM UWP MED] [float] NULL,
	[GLM UWP LGE] [float] NULL,
	[GLM UWP CAN] [float] NULL,
	[GLM UWP ADD] [float] NULL,
	[GLM UWP LUG] [float] NULL,
	[GLM UWP MIS] [float] NULL,
	[GLM UWP UDL] [float] NULL,
	[GLM UWP CAT] [float] NULL,
	[GLM UWP] [float] NULL,
	[Outlet Name] [nvarchar](50) NULL,
	[Outlet Sub Group Code] [nvarchar](50) NULL,
	[Outlet Sub Group Name] [nvarchar](50) NULL,
	[Outlet Group Code] [nvarchar](50) NULL,
	[Outlet Group Name] [nvarchar](50) NULL,
	[Outlet Super Group] [nvarchar](255) NULL,
	[Outlet Channel] [nvarchar](100) NULL,
	[Outlet BDM] [nvarchar](101) NULL,
	[Outlet Post Code] [nvarchar](50) NULL,
	[Outlet Sales State Area] [nvarchar](50) NULL,
	[Outlet Trading Status] [nvarchar](50) NULL,
	[Outlet Type] [nvarchar](50) NULL,
	[Latest Outlet Name] [nvarchar](50) NULL,
	[Latest Outlet Sub Group Code] [nvarchar](50) NULL,
	[Latest Outlet Sub Group Name] [nvarchar](50) NULL,
	[Latest Outlet Group Code] [nvarchar](50) NULL,
	[Latest Outlet Group Name] [nvarchar](50) NULL,
	[Latest Outlet Super Group] [nvarchar](255) NULL,
	[Latest Outlet Channel] [nvarchar](100) NULL,
	[Latest Outlet BDM] [nvarchar](101) NULL,
	[Latest Outlet Post Code] [nvarchar](50) NULL,
	[Latest Outlet Sales State Area] [nvarchar](50) NULL,
	[Latest Outlet Trading Status] [nvarchar](50) NULL,
	[Latest Outlet Type] [nvarchar](50) NULL,
	[Base CRM Username] [nvarchar](100) NULL,
	[CBA ChannelID] [nvarchar](50) NULL,
	[CBA Channel] [varchar](7) NULL,
	[JV Code] [nvarchar](20) NULL,
	[JV Description] [nvarchar](100) NULL,
	[Latest JV Code] [nvarchar](20) NULL,
	[Latest JV Description] [nvarchar](100) NULL,
	[Underwriter] [varchar](10) NOT NULL,
	[ClaimCount] [int] NULL,
	[SectionCount] [int] NULL,
	[SectionCountNonNil] [int] NULL,
	[NetIncurredMovementIncRecoveries] [decimal](38, 6) NULL,
	[NetPaymentMovementIncRecoveries] [decimal](38, 6) NULL,
	[Sections MED] [int] NULL,
	[Sections MED_LGE] [int] NULL,
	[Sections PRE_CAN] [int] NULL,
	[Sections PRE_CAN_LGE] [int] NULL,
	[Sections ON_CAN] [int] NULL,
	[Sections ON_CAN_LGE] [int] NULL,
	[Sections ADD] [int] NULL,
	[Sections ADD_LGE] [int] NULL,
	[Sections LUG] [int] NULL,
	[Sections LUG_LGE] [int] NULL,
	[Sections MIS] [int] NULL,
	[Sections MIS_LGE] [int] NULL,
	[Sections UDL] [int] NULL,
	[Sections UDL_LGE] [int] NULL,
	[Sections CAT] [int] NULL,
	[Sections COV] [int] NULL,
	[Sections OTH] [int] NULL,
	[Sections Non-Nil MED] [int] NULL,
	[Sections Non-Nil MED_LGE] [int] NULL,
	[Sections Non-Nil PRE_CAN] [int] NULL,
	[Sections Non-Nil PRE_CAN_LGE] [int] NULL,
	[Sections Non-Nil ON_CAN] [int] NULL,
	[Sections Non-Nil ON_CAN_LGE] [int] NULL,
	[Sections Non-Nil ADD] [int] NULL,
	[Sections Non-Nil ADD_LGE] [int] NULL,
	[Sections Non-Nil LUG] [int] NULL,
	[Sections Non-Nil LUG_LGE] [int] NULL,
	[Sections Non-Nil MIS] [int] NULL,
	[Sections Non-Nil MIS_LGE] [int] NULL,
	[Sections Non-Nil UDL] [int] NULL,
	[Sections Non-Nil UDL_LGE] [int] NULL,
	[Sections Non-Nil CAT] [int] NULL,
	[Sections Non-Nil COV] [int] NULL,
	[Sections Non-Nil OTH] [int] NULL,
	[Payments MED] [decimal](38, 6) NULL,
	[Payments MED_LGE] [decimal](38, 6) NULL,
	[Payments PRE_CAN] [decimal](38, 6) NULL,
	[Payments PRE_CAN_LGE] [decimal](38, 6) NULL,
	[Payments ON_CAN] [decimal](38, 6) NULL,
	[Payments ON_CAN_LGE] [decimal](38, 6) NULL,
	[Payments ADD] [decimal](38, 6) NULL,
	[Payments ADD_LGE] [decimal](38, 6) NULL,
	[Payments LUG] [decimal](38, 6) NULL,
	[Payments LUG_LGE] [decimal](38, 6) NULL,
	[Payments MIS] [decimal](38, 6) NULL,
	[Payments MIS_LGE] [decimal](38, 6) NULL,
	[Payments UDL] [decimal](38, 6) NULL,
	[Payments UDL_LGE] [decimal](38, 6) NULL,
	[Payments CAT] [decimal](38, 6) NULL,
	[Payments COV] [decimal](38, 6) NULL,
	[Payments OTH] [decimal](38, 6) NULL,
	[Incurred MED] [decimal](38, 6) NULL,
	[Incurred MED_LGE] [decimal](38, 6) NULL,
	[Incurred PRE_CAN] [decimal](38, 6) NULL,
	[Incurred PRE_CAN_LGE] [decimal](38, 6) NULL,
	[Incurred ON_CAN] [decimal](38, 6) NULL,
	[Incurred ON_CAN_LGE] [decimal](38, 6) NULL,
	[Incurred ADD] [decimal](38, 6) NULL,
	[Incurred ADD_LGE] [decimal](38, 6) NULL,
	[Incurred LUG] [decimal](38, 6) NULL,
	[Incurred LUG_LGE] [decimal](38, 6) NULL,
	[Incurred MIS] [decimal](38, 6) NULL,
	[Incurred MIS_LGE] [decimal](38, 6) NULL,
	[Incurred UDL] [decimal](38, 6) NULL,
	[Incurred UDL_LGE] [decimal](38, 6) NULL,
	[Incurred CAT] [decimal](38, 6) NULL,
	[Incurred COV] [decimal](38, 6) NULL,
	[Incurred OTH] [decimal](38, 6) NULL,
	[Youngest EMC DOB] [date] NULL,
	[Oldest EMC DOB] [date] NULL,
	[Youngest EMC Age] [int] NULL,
	[Oldest EMC Age] [int] NULL,
	[Gross Premium Adventure Activities] [money] NULL,
	[Gross Premium Aged Cover] [money] NULL,
	[Gross Premium Ancillary Products] [money] NULL,
	[Gross Premium Cancel For Any Reason] [money] NULL,
	[Gross Premium Cancellation] [money] NULL,
	[Gross Premium Cancellation Plus] [money] NULL,
	[Gross Premium COVID-19] [money] NULL,
	[Gross Premium Cruise] [money] NULL,
	[Gross Premium Electronics] [money] NULL,
	[Gross Premium Freely Packs] [money] NULL,
	[Gross Premium Luggage] [money] NULL,
	[Gross Premium Medical] [money] NULL,
	[Gross Premium Motorcycle] [money] NULL,
	[Gross Premium Rental Car] [money] NULL,
	[Gross Premium Ticket] [money] NULL,
	[Gross Premium Winter Sport] [money] NULL,
	[UnAdj Gross Premium Adventure Activities] [money] NULL,
	[UnAdj Gross Premium Aged Cover] [money] NULL,
	[UnAdj Gross Premium Ancillary Products] [money] NULL,
	[UnAdj Gross Premium Cancel For Any Reason] [money] NULL,
	[UnAdj Gross Premium Cancellation] [money] NULL,
	[UnAdj Gross Premium Cancellation Plus] [money] NULL,
	[UnAdj Gross Premium COVID-19] [money] NULL,
	[UnAdj Gross Premium Cruise] [money] NULL,
	[UnAdj Gross Premium Electronics] [money] NULL,
	[UnAdj Gross Premium Freely Packs] [money] NULL,
	[UnAdj Gross Premium Luggage] [money] NULL,
	[UnAdj Gross Premium Medical] [money] NULL,
	[UnAdj Gross Premium Motorcycle] [money] NULL,
	[UnAdj Gross Premium Rental Car] [money] NULL,
	[UnAdj Gross Premium Ticket] [money] NULL,
	[UnAdj Gross Premium Winter Sport] [money] NULL,
	[Addon Count Adventure Activities] [int] NULL,
	[Addon Count Aged Cover] [int] NULL,
	[Addon Count Ancillary Products] [int] NULL,
	[Addon Count Cancel For Any Reason] [int] NULL,
	[Addon Count Cancellation] [int] NULL,
	[Addon Count Cancellation Plus] [int] NULL,
	[Addon Count COVID-19] [int] NULL,
	[Addon Count Cruise] [int] NULL,
	[Addon Count Electronics] [int] NULL,
	[Addon Count Freely Packs] [int] NULL,
	[Addon Count Luggage] [int] NULL,
	[Addon Count Medical] [int] NULL,
	[Addon Count Motorcycle] [int] NULL,
	[Addon Count Rental Car] [int] NULL,
	[Addon Count Ticket] [int] NULL,
	[Addon Count Winter Sport] [int] NULL,
	[Promo Code] [nvarchar](40) NULL,
	[Promo Name] [nvarchar](250) NULL,
	[Promo Type] [nvarchar](50) NULL,
	[Promo Discount] [numeric](10, 4) NULL,
	[Sell Price - Total] [money] NULL,
	[Sell Price - Active] [money] NULL,
	[Sell Price - Active Base] [money] NULL,
	[Sell Price - Active Extension] [money] NULL,
	[Sell Price - Cancelled] [money] NULL,
	[Sell Price - Cancelled Base] [money] NULL,
	[Sell Price - Cancelled Extension] [money] NULL,
	[Premium - Total] [money] NULL,
	[Premium - Active] [money] NULL,
	[Premium - Active Base] [money] NULL,
	[Premium - Active Extension] [money] NULL,
	[Premium - Cancelled] [money] NULL,
	[Premium - Cancelled Base] [money] NULL,
	[Premium - Cancelled Extension] [money] NULL,
	[First Active Date] [datetime] NULL,
	[First Active Date - Base] [datetime] NULL,
	[First Active Date - Extension] [datetime] NULL,
	[Last Active Date] [datetime] NULL,
	[Last Active Date - Base] [datetime] NULL,
	[Last Active Date - Extension] [datetime] NULL,
	[First Cancelled Date] [datetime] NULL,
	[First Cancelled Date - Base] [datetime] NULL,
	[First Cancelled Date - Extension] [datetime] NULL,
	[Last Cancelled Date] [datetime] NULL,
	[Last Cancelled Date - Base] [datetime] NULL,
	[Last Cancelled Date - Extension] [datetime] NULL,
	[Days to Cancelled] [int] NULL,
	[Work Days to Cancelled] [int] NULL,
	[Policy Status Detailed] [varchar](32) NOT NULL,
	[Credit Note Number] [nvarchar](15) NULL,
	[Credit Note Issue Date] [datetime] NULL,
	[Credit Note Start Date] [datetime] NULL,
	[Credit Note Expiry Date] [datetime] NULL,
	[Credit Note Status] [varchar](15) NULL,
	[Credit Note Amount] [money] NULL,
	[Credit Note Amount Redeemed] [money] NULL,
	[Credit Note Amount Remaining] [money] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Policy_Header_Works_PolicyKey]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE CLUSTERED INDEX [idx_Policy_Header_Works_PolicyKey] ON [cng].[Policy_Header]
(
	[PolicyKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_Policy_Header_Works_PolicyKeyProductCode]    Script Date: 21/02/2025 11:15:50 AM ******/
CREATE NONCLUSTERED INDEX [idx_Policy_Header_Works_PolicyKeyProductCode] ON [cng].[Policy_Header]
(
	[PolicyKey] ASC,
	[Product Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
