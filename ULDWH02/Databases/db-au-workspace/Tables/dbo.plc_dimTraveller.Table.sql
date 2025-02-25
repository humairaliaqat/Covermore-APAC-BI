USE [db-au-workspace]
GO
/****** Object:  Table [dbo].[plc_dimTraveller]    Script Date: 24/02/2025 5:22:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[plc_dimTraveller](
	[TravellerSK] [bigint] IDENTITY(1,1) NOT NULL,
	[TravellerKey] [varchar](50) NOT NULL,
	[FirstName] [nvarchar](100) NULL,
	[LastName] [nvarchar](100) NULL,
	[DOB] [datetime] NULL,
	[Email] [nvarchar](255) NULL,
	[WorkPhone] [nvarchar](100) NULL,
	[HomePhone] [nvarchar](100) NULL,
	[Mobile] [nvarchar](100) NULL,
	[EMCNumber] [nvarchar](20) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_plcdimTraveller_TravellerSK]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE CLUSTERED INDEX [idx_plcdimTraveller_TravellerSK] ON [dbo].[plc_dimTraveller]
(
	[TravellerSK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_plcdimTraveller_TravellerKey]    Script Date: 24/02/2025 5:22:17 PM ******/
CREATE NONCLUSTERED INDEX [idx_plcdimTraveller_TravellerKey] ON [dbo].[plc_dimTraveller]
(
	[TravellerKey] ASC
)
INCLUDE([FirstName],[LastName],[DOB],[EMCNumber]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
