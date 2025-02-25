USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[usrTDS_Policy]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrTDS_Policy](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[BatchID] [int] NULL,
	[travel_insurance_ref_id] [varchar](50) NULL,
	[travel_departure_date] [datetime] NOT NULL,
	[travel_return_date] [datetime] NOT NULL,
	[travel_countries] [varchar](200) NOT NULL,
	[policy_number] [varchar](20) NOT NULL,
	[quote_reference] [varchar](50) NULL,
	[policy_status_code] [varchar](10) NOT NULL,
	[type_code] [varchar](10) NOT NULL,
	[promo_code] [varchar](20) NULL,
	[total_premium] [money] NULL,
	[total_cost_to_cba] [money] NULL,
	[commission] [money] NULL,
	[gst] [money] NULL,
	[stamp_duty] [money] NULL,
	[commission_gst] [money] NULL,
	[commission_stamp_duty] [money] NULL,
	[base_premium] [money] NULL,
	[medical_premium] [money] NULL,
	[emc_premium] [money] NULL,
	[cruise_premium] [money] NULL,
	[luggage_premium] [money] NULL,
	[winter_sport_premium] [money] NULL,
	[business_premium] [money] NULL,
	[age_cover_premium] [money] NULL,
	[rental_car_premium] [money] NULL,
	[motorcycle_premium] [money] NULL,
	[other_packs_premium] [money] NULL,
	[discount] [money] NULL,
	[policy_count] [int] NULL,
	[policy_pack_count] [int] NULL,
	[initiating_channel_code] [varchar](10) NULL,
	[csr_reference] [varchar](50) NULL,
	[customer_group_name] [varchar](100) NULL,
	[customer_travel_group] [varchar](15) NULL,
	[excess] [money] NULL,
	[trip_cost] [money] NULL,
	[issued_date] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [ucidx_usrTDS_Policy]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE UNIQUE CLUSTERED INDEX [ucidx_usrTDS_Policy] ON [dbo].[usrTDS_Policy]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrTDS_Policy_BatchID]    Script Date: 24/02/2025 5:22:18 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrTDS_Policy_BatchID] ON [dbo].[usrTDS_Policy]
(
	[BatchID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[usrTDS_Policy] ADD  DEFAULT (newid()) FOR [travel_insurance_ref_id]
GO
