USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Quote_Tbl_Blue_Insurence]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Quote_Tbl_Blue_Insurence](
	[Policy_Number] [varchar](50) NULL,
	[Quote_Date] [datetime] NULL,
	[Lead_Number] [int] NULL,
	[GCLID] [nvarchar](1000) NULL,
	[GA_Client_ID] [nvarchar](1000) NULL,
	[Link_ID] [varchar](500) NULL,
	[Marketing_Opt_Out] [varchar](1) NULL,
	[Travel_Countries_List] [nvarchar](max) NULL,
	[Primary_Country] [varchar](1) NULL,
	[Number_of_Countries] [bigint] NULL,
	[Region_List] [nvarchar](4000) NULL,
	[Departure_Date] [datetime] NULL,
	[Return_Date] [datetime] NULL,
	[Trip_Duration] [int] NULL,
	[Excess_Amount] [numeric](10, 4) NULL,
	[Cancellation_Sum_Insured] [varchar](300) NULL,
	[Cruise_Flag] [varchar](300) NULL,
	[Adventure_Activities_Flag] [nvarchar](50) NULL,
	[Motorbike_Flag] [nvarchar](50) NULL,
	[Snow_Sports_Flag] [nvarchar](50) NULL,
	[Luggage_Flag] [varchar](3) NULL,
	[PEMC_Flag] [varchar](3) NULL,
	[Covid_Flag] [varchar](3) NULL,
	[Quoted_Base_Premium] [varchar](500) NULL,
	[Quoted_Cancellation_Premium] [numeric](10, 4) NULL,
	[Quoted_Snow_Sports_Premium] [numeric](10, 4) NULL,
	[Quoted_Adventure_Activities_Premium] [numeric](10, 4) NULL,
	[Quoted_Motorcycle_Premium] [numeric](10, 4) NULL,
	[Quoted_Luggage_Premium] [numeric](10, 4) NULL,
	[Quoted_PEMC_Premium] [numeric](10, 4) NULL,
	[Quoted_Covid_Premium] [numeric](10, 4) NULL,
	[Quoted_Cruise_Premium] [numeric](10, 4) NULL,
	[Total_Quoted_Premium] [numeric](10, 4) NULL,
	[Total_Quoted_Gross_Premium] [numeric](19, 4) NULL,
	[NAP] [money] NULL,
	[Policy_Holder_Title] [nvarchar](500) NULL,
	[Policy_Holder_First_Name] [nvarchar](500) NULL,
	[Policy_Holder_Surname] [nvarchar](500) NULL,
	[Policy_Holder_Email] [nvarchar](255) NULL,
	[Policy_Holder_Mobile_Phone] [varchar](50) NULL,
	[Policy_Holder_Address] [nvarchar](4000) NULL,
	[Policy_Holder_DOB] [datetime] NULL,
	[Policy_Holder_Age] [int] NULL,
	[Policy_Holder_State] [nvarchar](100) NULL,
	[Oldest_Traveller_DOB] [datetime] NULL,
	[Oldest_Traveller_Age] [int] NULL,
	[Agency_Code] [nvarchar](255) NULL,
	[Agency_Name] [varchar](13) NULL,
	[Brand] [varchar](13) NULL,
	[Channel_Type] [varchar](13) NULL,
	[Promotional_Code] [nvarchar](max) NULL,
	[Promotional_Factor] [varchar](110) NULL,
	[Session_Token] [nvarchar](255) NULL,
	[Copy of Travel_Countries_List] [nvarchar](500) NULL,
	[Copy of Promotional_Code] [nvarchar](500) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
