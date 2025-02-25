USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Quote_Data_Sample]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Quote_Data_Sample](
	[Policy_Number] [varchar](50) NULL,
	[Quote_Date] [varchar](50) NULL,
	[Lead_Number] [varchar](50) NULL,
	[GCLID] [varchar](50) NULL,
	[GA_Client_ID] [varchar](50) NULL,
	[Link_ID] [varchar](50) NULL,
	[Marketing_Opt_Out] [varchar](50) NULL,
	[Travel_Countries_List] [nvarchar](500) NULL,
	[Primary_Country] [varchar](50) NULL,
	[Number_of_Countries] [varchar](50) NULL,
	[Region_List] [varchar](50) NULL,
	[Departure_Date] [varchar](50) NULL,
	[Return_Date] [varchar](50) NULL,
	[Trip_Duration] [varchar](50) NULL,
	[Excess_Amount] [varchar](50) NULL,
	[Cancellation_Sum_Insured] [varchar](50) NULL,
	[Cruise_Flag] [varchar](50) NULL,
	[Adventure_Activities_Flag] [varchar](50) NULL,
	[Motorbike_Flag] [varchar](50) NULL,
	[Snow_Sports_Flag] [varchar](50) NULL,
	[Luggage_Flag] [varchar](50) NULL,
	[PEMC_Flag] [varchar](50) NULL,
	[Covid_Flag] [varchar](50) NULL,
	[Quoted_Base_Premium] [varchar](50) NULL,
	[Quoted_Cancellation_Premium] [varchar](50) NULL,
	[Quoted_Snow_Sports_Premium] [varchar](50) NULL,
	[Quoted_Adventure_Activities_Premium] [varchar](50) NULL,
	[Quoted_Motorcycle_Premium] [varchar](50) NULL,
	[Quoted_Luggage_Premium] [varchar](50) NULL,
	[Quoted_PEMC_Premium] [varchar](50) NULL,
	[Quoted_Covid_Premium] [varchar](50) NULL,
	[Quoted_Cruise_Premium] [varchar](50) NULL,
	[Total_Quoted_Premium] [varchar](50) NULL,
	[Total_Quoted_Gross_Premium] [nvarchar](500) NULL,
	[NAP] [nvarchar](50) NULL,
	[Policy_Holder_Title] [varchar](50) NULL,
	[Policy_Holder_First_Name] [varchar](50) NULL,
	[Policy_Holder_Surname] [varchar](50) NULL,
	[Policy_Holder_Email] [varchar](50) NULL,
	[Policy_Holder_Mobile_Phone] [varchar](50) NULL,
	[Policy_Holder_Address] [nvarchar](500) NULL,
	[Policy_Holder_DOB] [varchar](500) NULL,
	[Policy_Holder_Age] [varchar](50) NULL,
	[Policy_Holder_State] [varchar](50) NULL,
	[Oldest_Traveller_DOB] [varchar](50) NULL,
	[Oldest_Traveller_Age] [varchar](50) NULL,
	[Agency_Code] [varchar](50) NULL,
	[Agency_Name] [varchar](50) NULL,
	[Brand] [varchar](50) NULL,
	[Channel_Type] [varchar](50) NULL,
	[Promotional_Code] [varchar](50) NULL,
	[Promotional_Factor] [varchar](50) NULL,
	[Session_Token] [varchar](50) NULL
) ON [PRIMARY]
GO
