USE [db-au-stage]
GO
/****** Object:  Table [dbo].[eFrontOfficeDW_vwpnpServiceBilling_audtc]    Script Date: 24/02/2025 5:08:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[eFrontOfficeDW_vwpnpServiceBilling_audtc](
	[ServiceFileId] [int] NOT NULL,
	[ServiceEventID] [int] NOT NULL,
	[ServiceEventActivtiyID] [int] NOT NULL,
	[ServiceEventActivityInvID] [int] NULL,
	[CoverageID] [int] NULL,
	[FunderID] [int] NULL,
	[invDate] [date] NULL,
	[invlineqty] [numeric](10, 2) NULL,
	[invlineamt] [numeric](10, 2) NULL,
	[invlinepaid] [varchar](5) NULL,
	[kinvoicenoid] [int] NULL,
	[batchno] [int] NULL,
	[batchposted] [bit] NULL,
	[batchpostdate] [datetime] NULL,
	[ActivityStatus] [nvarchar](25) NOT NULL,
	[EventType] [nvarchar](25) NOT NULL,
	[EventStart] [datetime2](7) NOT NULL,
	[EventEnd] [datetime2](7) NOT NULL,
	[CartItem] [nvarchar](40) NOT NULL,
	[Service] [varchar](80) NOT NULL,
	[ServiceID] [int] NULL,
	[revglcode] [varchar](10) NOT NULL,
	[serglcode] [varchar](10) NOT NULL,
	[ItemDeleted] [datetime] NULL,
	[PenelopeCompositeID] [varchar](30) NULL
) ON [PRIMARY]
GO
