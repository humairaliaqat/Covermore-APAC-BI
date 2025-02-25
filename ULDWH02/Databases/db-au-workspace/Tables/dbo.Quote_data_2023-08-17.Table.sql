USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[Quote_data_2023-08-17]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Quote_data_2023-08-17](
	[ Policy_Number ] [nvarchar](50) NULL,
	[ Quote_Date ] [nvarchar](50) NULL,
	[ Lead_Number ] [nvarchar](50) NULL,
	[ GCLID ] [nvarchar](50) NULL,
	[ GA_Client_ID ] [nvarchar](50) NULL,
	[ Link_ID ] [nvarchar](50) NULL,
	[ Marketing_Opt_Out ] [nvarchar](50) NULL,
	[ Travel_Countries_List ] [nvarchar](50) NULL,
	[ Primary_Country ] [nvarchar](50) NULL,
	[ Number_of_Countries ] [nvarchar](50) NULL,
	[ Region_List ] [nvarchar](50) NULL,
	[ Departure_Date ] [nvarchar](50) NULL,
	[ Return_Date ] [nvarchar](50) NULL,
	[ Trip_Duration ] [nvarchar](50) NULL,
	[ Excess_Amount ] [nvarchar](50) NULL,
	[ Cancellation_Sum_Insured ] [nvarchar](50) NULL,
	[ Cruise_Flag ] [nvarchar](50) NULL,
	[ Adventure_Activities_Flag ] [nvarchar](50) NULL,
	[ Motorbike_Flag ] [nvarchar](50) NULL,
	[ Snow_Sports_Flag ] [nvarchar](50) NULL,
	[ Luggage_Flag ] [nvarchar](50) NULL,
	[ PEMC_Flag ] [nvarchar](50) NULL,
	[ Covid_Flag ] [nvarchar](50) NULL,
	[ Quoted_Base_Premium ] [nvarchar](50) NULL,
	[ Quoted_Cancellation_Premium ] [nvarchar](50) NULL,
	[ Quoted_Snow_Sports_Premium ] [nvarchar](50) NULL,
	[ Quoted_Adventure_Activities_Premium ] [nvarchar](50) NULL,
	[ Quoted_Motorcycle_Premium ] [nvarchar](50) NULL,
	[ Quoted_Luggage_Premium ] [nvarchar](50) NULL,
	[ Quoted_PEMC_Premium ] [nvarchar](50) NULL,
	[ Quoted_Covid_Premium ] [nvarchar](50) NULL,
	[ Quoted_Cruise_Premium ] [nvarchar](50) NULL,
	[ Total_Quoted_Premium ] [nvarchar](50) NULL,
	[ Total_Quoted_Gross_Premium ] [nvarchar](50) NULL,
	[ NAP ] [nvarchar](50) NULL,
	[ Policy_Holder_Title ] [nvarchar](50) NULL,
	[ Policy_Holder_First_Name ] [nvarchar](50) NULL,
	[ Policy_Holder_Surname ] [nvarchar](50) NULL,
	[ Policy_Holder_Email ] [nvarchar](50) NULL,
	[ Policy_Holder_Mobile_Phone ] [nvarchar](50) NULL,
	[ Policy_Holder_Address ] [nvarchar](50) NULL,
	[ Policy_Holder_DOB ] [nvarchar](50) NULL,
	[ Policy_Holder_Age ] [nvarchar](50) NULL,
	[ Policy_Holder_State ] [nvarchar](50) NULL,
	[ Oldest_Traveller_DOB ] [nvarchar](50) NULL,
	[ Oldest_Traveller_Age ] [nvarchar](50) NULL,
	[ Agency_Code ] [nvarchar](50) NULL,
	[ Agency_Name ] [nvarchar](50) NULL,
	[ Brand ] [nvarchar](50) NULL,
	[ Channel_Type ] [nvarchar](50) NULL,
	[ Promotional_Code ] [nvarchar](50) NULL,
	[ Promotional_Factor ] [nvarchar](50) NULL,
	[ Session_Token ] [nvarchar](50) NULL
) ON [PRIMARY]
GO
