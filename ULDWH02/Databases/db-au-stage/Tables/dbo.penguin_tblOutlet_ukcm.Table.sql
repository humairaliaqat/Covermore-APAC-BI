USE [db-au-stage]
GO
/****** Object:  Table [dbo].[penguin_tblOutlet_ukcm]    Script Date: 24/02/2025 5:08:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[penguin_tblOutlet_ukcm](
	[OutletId] [int] NOT NULL,
	[SubGroupID] [int] NOT NULL,
	[OutletName] [nvarchar](50) NOT NULL,
	[OutletTypeID] [int] NOT NULL,
	[AlphaCode] [nvarchar](20) NOT NULL,
	[OTPId] [int] NOT NULL,
	[OTCId] [int] NOT NULL,
	[StatusValue] [int] NOT NULL,
	[CommencementDate] [datetime] NULL,
	[CloseDate] [datetime] NULL,
	[PreviousAlpha] [nvarchar](20) NULL,
	[StatusRegion] [int] NULL,
	[DomainId] [int] NOT NULL,
	[StatusReasonComment] [nvarchar](100) NULL,
	[isDefault] [bit] NULL,
	[JointVentureId] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblOutlet_ukcm_OutletID]    Script Date: 24/02/2025 5:08:05 PM ******/
CREATE CLUSTERED INDEX [idx_penguin_tblOutlet_ukcm_OutletID] ON [dbo].[penguin_tblOutlet_ukcm]
(
	[OutletId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_penguin_tblOutlet_ukcm_AlphaCode]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_penguin_tblOutlet_ukcm_AlphaCode] ON [dbo].[penguin_tblOutlet_ukcm]
(
	[AlphaCode] ASC
)
INCLUDE([OutletId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_penguin_tblOutlet_ukcm_DomainID]    Script Date: 24/02/2025 5:08:07 PM ******/
CREATE NONCLUSTERED INDEX [idx_penguin_tblOutlet_ukcm_DomainID] ON [dbo].[penguin_tblOutlet_ukcm]
(
	[OutletId] ASC
)
INCLUDE([DomainId]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
