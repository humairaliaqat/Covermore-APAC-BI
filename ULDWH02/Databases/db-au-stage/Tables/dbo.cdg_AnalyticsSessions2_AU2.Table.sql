USE [db-au-stage]
GO
/****** Object:  Table [dbo].[cdg_AnalyticsSessions2_AU2]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdg_AnalyticsSessions2_AU2](
	[id] [bigint] NOT NULL,
	[campaign_session_id] [nvarchar](4000) NOT NULL,
	[traveller_id] [nvarchar](4000) NOT NULL,
	[impression_id] [nvarchar](4000) NULL,
	[business_unit_id] [smallint] NOT NULL,
	[channel_id] [smallint] NOT NULL,
	[transaction_time] [datetime2](7) NULL,
	[campaign_id] [smallint] NOT NULL,
	[construct_id] [nvarchar](4000) NULL,
	[offer_id] [nvarchar](4000) NULL,
	[product_id] [smallint] NULL,
	[start_date] [date] NULL,
	[end_date] [date] NULL,
	[region_id] [smallint] NULL,
	[destination_type] [nchar](1) NULL,
	[destination_country_id] [int] NULL,
	[trip_type] [nchar](1) NULL,
	[is_session_closed] [varchar](5) NULL,
	[is_offer_purchased] [varchar](5) NULL,
	[policies_per_trip] [smallint] NULL,
	[policy_currency] [nchar](3) NULL,
	[gross_including_tax] [numeric](28, 6) NULL,
	[gross_excluding_tax] [numeric](28, 6) NULL,
	[num_adults] [smallint] NOT NULL,
	[num_children] [smallint] NOT NULL,
	[traveller_age] [smallint] NULL,
	[is_adult] [varchar](5) NOT NULL,
	[traveller_gender] [nchar](1) NULL,
	[is_primary_traveller] [varchar](5) NULL,
	[alpha_code] [nvarchar](4000) NULL,
	[policy_number] [nvarchar](4000) NULL,
	[policy_id] [nvarchar](4000) NULL,
	[trip_cost] [numeric](28, 6) NULL,
	[departure_airport_code] [nvarchar](4000) NULL,
	[destination_airport_code] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
