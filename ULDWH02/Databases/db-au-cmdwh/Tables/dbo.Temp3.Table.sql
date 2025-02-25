USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Temp3]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Temp3](
	[id] [nvarchar](255) NULL,
	[Trans_date] [date] NULL,
	[partner] [varchar](4) NOT NULL,
	[underwriter] [varchar](10) NOT NULL,
	[quote_slug] [nvarchar](255) NULL,
	[quote_id] [int] NULL,
	[quote_status] [varchar](1) NOT NULL,
	[created_datetime] [date] NULL,
	[updated_datetime] [varchar](1) NOT NULL,
	[product_class] [varchar](6) NOT NULL,
	[product_slug] [nvarchar](100) NULL,
	[product_type] [nvarchar](100) NULL,
	[payment_freq] [varchar](1) NOT NULL,
	[premium.retail_premium_taxes] [numeric](19, 4) NULL,
	[premium.retail_premium_incl_taxes] [varchar](1) NOT NULL,
	[commencement_date] [datetime] NULL,
	[expiry_date] [datetime] NULL,
	[policy_holder.dob] [datetime] NULL,
	[policy_holder.email] [nvarchar](255) NULL,
	[policy_holder.mobile] [varchar](50) NULL,
	[policy_holder.last_name] [varchar](500) NULL,
	[policy_holder.first_name] [varchar](500) NULL,
	[risk_address.gnaf] [nvarchar](256) NULL,
	[risk_address.state] [nvarchar](4000) NULL,
	[risk_address.suburb] [nvarchar](4000) NULL,
	[risk_address.country] [varchar](1) NOT NULL,
	[risk_address.postcode] [nvarchar](50) NULL,
	[risk_address.street_name] [nvarchar](4000) NULL,
	[risk_address.street_type] [nvarchar](4000) NULL,
	[risk_address.unit_number] [nvarchar](4000) NULL,
	[risk_address.street_number] [nvarchar](4000) NULL,
	[risk_address.full] [nvarchar](4000) NULL,
	[postal_address] [nvarchar](4000) NULL,
	[open_customer_ref] [varchar](1) NOT NULL,
	[bupa_customer_ref_ref] [varchar](1) NOT NULL,
	[channel] [varchar](11) NULL,
	[sum_insured.travel] [varchar](300) NOT NULL,
	[excess.travel] [decimal](10, 4) NULL,
	[promo_code] [nvarchar](max) NOT NULL,
	[additional_info.bupa_id] [varchar](1) NOT NULL,
	[additional_info.agent_id] [varchar](1) NOT NULL,
	[additional_info.agent_name] [varchar](1) NOT NULL,
	[additional_info.HI_product] [varchar](1) NOT NULL,
	[additional_info.employee_num] [varchar](1) NOT NULL,
	[additional_info.cgu_policy_no] [varchar](1) NOT NULL,
	[additional_info.HI_member_type] [varchar](1) NOT NULL,
	[additional_info.employee_group] [varchar](1) NOT NULL,
	[additional_info.HI_membership_num] [nvarchar](25) NULL,
	[additional_info.HI_member_discount] [varchar](1) NOT NULL,
	[additional_info.employee_validated] [varchar](1) NOT NULL,
	[additional_info.HI_member_validated] [varchar](3) NOT NULL,
	[additional_info.HI_member_num_suffix] [nvarchar](25) NULL,
	[additional_info.cgu_policy_inception_date] [varchar](1) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
