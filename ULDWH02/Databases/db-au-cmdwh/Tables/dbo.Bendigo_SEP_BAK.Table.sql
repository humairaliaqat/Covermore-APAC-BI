USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[Bendigo_SEP_BAK]    Script Date: 24/02/2025 12:39:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bendigo_SEP_BAK](
	[Reference number] [varchar](100) NULL,
	[Quote reference number] [int] NULL,
	[Quote saved date] [datetime] NULL,
	[Policy number] [varchar](50) NULL,
	[User id] [nvarchar](4000) NULL,
	[User name] [nvarchar](4000) NULL,
	[Branch id] [nvarchar](20) NULL,
	[Branch name] [nvarchar](4000) NULL,
	[Scheme/ Promotion] [nvarchar](4000) NULL,
	[Transaction type] [varchar](50) NULL,
	[Call type] [nvarchar](4000) NULL,
	[Customer given name 1] [nvarchar](4000) NULL,
	[Customer surname 1] [nvarchar](4000) NULL,
	[Customer DOB 1] [datetime] NULL,
	[Member number 1] [int] NULL,
	[Customer given name 2] [nvarchar](4000) NULL,
	[Customer surname 2] [nvarchar](4000) NULL,
	[Customer DOB 2] [datetime] NULL,
	[Member number 2] [int] NULL,
	[Customer given name 3] [nvarchar](4000) NULL,
	[Customer surname 3] [nvarchar](4000) NULL,
	[Customer DOB 3] [datetime] NULL,
	[Member number 3] [int] NULL,
	[Customer given name 4] [nvarchar](4000) NULL,
	[Customer surname 4] [nvarchar](4000) NULL,
	[Customer DOB 4] [datetime] NULL,
	[Member number 4] [int] NULL,
	[Customer given name 5] [nvarchar](4000) NULL,
	[Customer surname 5] [nvarchar](4000) NULL,
	[Customer DOB 5] [datetime] NULL,
	[Member number 5] [int] NULL,
	[Risk suburb] [nvarchar](4000) NULL,
	[Risk postcode] [nvarchar](256) NULL,
	[Risk type] [varchar](6) NULL,
	[Cover type] [nvarchar](4000) NULL,
	[Quote 1 product name] [nvarchar](4000) NULL,
	[Quote 1 premium] [numeric](19, 4) NULL,
	[Quote 1 excess] [money] NULL,
	[Quote 2 product name] [nvarchar](4000) NULL,
	[Quote 2 premium] [numeric](19, 4) NULL,
	[Quote 2 excess] [money] NULL,
	[Quote 3 product name] [nvarchar](4000) NULL,
	[Quote 3 premium] [numeric](19, 4) NULL,
	[Quote 3 excess] [money] NULL,
	[Policy excess] [money] NULL,
	[Building premium] [int] NULL,
	[Contents premium] [int] NULL,
	[Liability premium] [int] NULL,
	[Specified contents premium] [int] NULL,
	[Unspecified valuables premium] [int] NULL,
	[Specified valuables premium] [int] NULL,
	[Motor vehicle cover] [nvarchar](50) NULL,
	[Protected no claim bonus cover] [int] NULL,
	[Windscreen option selected] [int] NULL,
	[Motor premium] [money] NULL,
	[Interested party] [int] NULL,
	[Destination] [nvarchar](max) NULL,
	[Plan type] [nvarchar](4000) NULL,
	[Payment type] [varchar](8000) NULL,
	[Payment frequency] [int] NULL,
	[Policy Premium GWP] [money] NULL,
	[Policy Premium Total] [money] NULL,
	[Cruise_cover] [varchar](3) NULL,
	[Ski_cover] [nvarchar](50) NULL,
	[Specific_luggage_cover] [varchar](3) NULL,
	[Specific_luggage_cover_sum_insured] [money] NULL,
	[Insured_age_1] [int] NULL,
	[Insured_age_2] [int] NULL,
	[Annual_multi_trip_duration] [int] NULL,
	[Cancellation_only_sum_insured] [nvarchar](50) NULL,
	[Copy of Destination] [varchar](max) NULL,
	[Copy of User id] [varchar](2000) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
