USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[QuoteFeed_TBL]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QuoteFeed_TBL](
	[Extract date] [datetime] NULL,
	[quote_id] [int] NULL,
	[created_datetime] [datetime] NULL,
	[policy_number] [varchar](50) NULL,
	[eff_start_date] [datetime] NULL,
	[eff_end_date] [datetime] NULL,
	[slug] [nvarchar](255) NULL,
	[travel_country_list] [nvarchar](max) NULL,
	[region_list] [nvarchar](4000) NULL,
	[Plan_Code] [nvarchar](50) NULL,
	[Plan] [nvarchar](100) NULL,
	[Partner] [varchar](4) NULL,
	[Channe] [varchar](11) NULL,
	[Insured_num_of_adults] [int] NULL,
	[Insured_num_of_childs] [int] NULL,
	[Total_number_of_insured] [int] NULL,
	[trip_duration] [int] NULL,
	[Additional cover.Cruise_Flag] [varchar](300) NULL,
	[Additional cover.Covid_Flag] [varchar](300) NULL,
	[Additional cover.Luggage_Flag] [varchar](300) NULL,
	[Additional cover.Snow_Sports_Flag] [nvarchar](50) NULL,
	[Additional cover.Adventure_Activities_Flag] [nvarchar](50) NULL,
	[Additional cover.Motorbike_Flag] [nvarchar](100) NULL,
	[Additional cover.PEMC_Flag] [varchar](300) NULL,
	[Total_premium] [money] NULL,
	[Premium breakdown.Base_Premium] [decimal](10, 4) NULL,
	[Premium breakdown.Total_Gross_Premium] [numeric](19, 4) NULL,
	[Premium breakdown.Cruise_Premium] [decimal](10, 4) NULL,
	[Premium breakdown.Adventure_Activities_Premium] [decimal](10, 4) NULL,
	[Premium breakdown.Motorcycle_Premium] [decimal](10, 4) NULL,
	[Premium breakdown.Cancellation_Premium] [decimal](10, 4) NULL,
	[Premium breakdown.Covid_Premium] [decimal](10, 4) NULL,
	[Premium breakdown.Luggage_Premium] [decimal](10, 4) NULL,
	[Premium breakdown.Snow_Sports_Premium] [decimal](10, 4) NULL,
	[Premium breakdown.PEMC_Premium] [decimal](10, 4) NULL,
	[Premium breakdown.GST_on_Total_Premium] [decimal](10, 4) NULL,
	[Premium breakdown.Stamp_Duty_on_Total_Premium] [decimal](10, 4) NULL,
	[NAP] [decimal](19, 4) NULL,
	[Excess] [decimal](10, 4) NULL,
	[Cancellation_sum_insured] [varchar](300) NULL,
	[policy_holder.title] [nvarchar](4000) NULL,
	[policy_holder.first_name] [nvarchar](4000) NULL,
	[policy_holder.last_name] [nvarchar](4000) NULL,
	[policy_holder.email] [nvarchar](255) NULL,
	[policy_holder.mobile] [varchar](50) NULL,
	[policy_holder.dob] [datetime] NULL,
	[policy_holder.age] [int] NULL,
	[policy_holder.address] [nvarchar](4000) NULL,
	[policy_holder.state] [nvarchar](100) NULL,
	[policy_holder.postcode] [nvarchar](50) NULL,
	[policy_holder.GNAF] [nvarchar](256) NULL,
	[CreatedDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
