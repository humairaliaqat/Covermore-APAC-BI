USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Policy_Tbl]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Policy_Tbl](
	[Posting_Date] [varchar](100) NULL,
	[Policy_Number] [varchar](50) NULL,
	[Transaction_Type] [varchar](50) NULL,
	[Transaction_Sequence_Number] [varchar](41) NULL,
	[Transaction_Status] [nvarchar](50) NULL,
	[Transaction_Date] [varchar](100) NULL,
	[Sold_Date] [datetime] NULL,
	[Travel_Countries_List] [nvarchar](max) NULL,
	[Number_of_Countries] [bigint] NULL,
	[Primary_Country] [varchar](1) NULL,
	[Region_List] [nvarchar](4000) NULL,
	[Primary_Region] [nvarchar](4000) NULL,
	[Area_No] [varchar](20) NULL,
	[Area_Type] [varchar](25) NULL,
	[Departure_Date] [datetime] NULL,
	[Days_To_Departure] [int] NULL,
	[Return_Date] [datetime] NULL,
	[Trip_Duration] [int] NULL,
	[Trip_Type] [nvarchar](50) NULL,
	[Plan_Code] [nvarchar](50) NULL,
	[Plan] [nvarchar](50) NULL,
	[Single_Family] [varchar](6) NULL,
	[Number_of_Adults] [int] NULL,
	[Number_of_Children] [int] NULL,
	[Total_Number_of_Insured] [int] NULL,
	[Excess_Amount] [numeric](10, 4) NULL,
	[Cancellation_Sum_Insured] [nvarchar](50) NULL,
	[Cruise_Flag] [varchar](3) NULL,
	[Covid_Flag] [varchar](3) NULL,
	[Luggage_Flag] [varchar](3) NULL,
	[Snow_Sports_Flag] [nvarchar](50) NULL,
	[Adventure_Activities_Flag] [nvarchar](50) NULL,
	[Motorbike_Flag] [nvarchar](50) NULL,
	[PEMC_Flag] [varchar](3) NULL,
	[Base_Premium] [numeric](10, 4) NULL,
	[Total_Gross_Premium] [numeric](10, 4) NULL,
	[Cruise_Premium] [numeric](10, 4) NULL,
	[Adventure_Activities_Premium] [numeric](10, 4) NULL,
	[Motorcycle_Premium] [numeric](10, 4) NULL,
	[Cancellation_Premium] [numeric](10, 4) NULL,
	[Covid_Premium] [numeric](10, 4) NULL,
	[Luggage_Premium] [numeric](10, 4) NULL,
	[Snow_Sports_Premium] [numeric](10, 4) NULL,
	[PEMC_Premium] [numeric](10, 4) NULL,
	[Total_Premium] [numeric](10, 4) NULL,
	[GST_on_Total_Premium] [numeric](10, 4) NULL,
	[Stamp_Duty_on_Total_Premium] [numeric](10, 4) NULL,
	[NAP] [numeric](10, 4) NULL,
	[Policy_Holder_Title] [varchar](500) NULL,
	[Policy_Holder_First_Name] [varchar](500) NULL,
	[Policy_Holder_Surname] [varchar](500) NULL,
	[Policy_Holder_Email] [nvarchar](255) NULL,
	[Policy_Holder_Mobile_Phone] [varchar](50) NULL,
	[Policy_Holder_State] [nvarchar](100) NULL,
	[Policy_Holder_DOB] [datetime] NULL,
	[Policy_Holder_Age] [int] NULL,
	[Policy_Holder_PostCode] [nvarchar](50) NULL,
	[Policy_Holder_Address] [nvarchar](4000) NULL,
	[Oldest_Traveller_DOB] [datetime] NULL,
	[Oldest_Traveller_Age] [int] NULL,
	[Agency_Code] [nvarchar](20) NULL,
	[Agency_Name] [varchar](13) NULL,
	[Channel_Type] [varchar](13) NULL,
	[Brand] [varchar](13) NULL,
	[Promotional_Code] [nvarchar](20) NULL,
	[Promotional_Factor] [varchar](50) NULL,
	[Commission_Amount] [numeric](10, 4) NULL,
	[New_Policy_Count] [int] NULL,
	[Policy_Holder_GNAF] [nvarchar](256) NULL,
	[CreatedDate] [datetime] NULL,
	[Quote_Reference_ID] [varchar](500) NULL,
	[Quote_Transaction_ID] [varchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [NonClusteredIndex-20250131-052819]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20250131-052819] ON [dbo].[Policy_Tbl]
(
	[Transaction_Sequence_Number] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
