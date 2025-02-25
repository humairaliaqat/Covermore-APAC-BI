USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[usrFLTicketData]    Script Date: 24/02/2025 12:39:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[usrFLTicketData](
	[CountryKey] [varchar](2) NULL,
	[CompanyKey] [varchar](2) NULL,
	[OutletKey] [varchar](33) NULL,
	[OutletID] [int] NULL,
	[OutletAlphaKey] [varchar](33) NULL,
	[AlphaCode] [varchar](20) NULL,
	[OutletName] [varchar](50) NULL,
	[IssuedDate] [datetime] NULL,
	[ExtID] [nvarchar](255) NULL,
	[FLTicketCountINT] [float] NULL,
	[FLTicketCountDOM] [float] NULL,
	[CMPolicyCountINT] [float] NULL,
	[CMPolicyCountDOM] [float] NULL,
	[PCC] [nvarchar](20) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrFLTicketData_OutletKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE CLUSTERED INDEX [idx_usrFLTicketData_OutletKey] ON [dbo].[usrFLTicketData]
(
	[OutletKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrFLTicketData_ExtID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrFLTicketData_ExtID] ON [dbo].[usrFLTicketData]
(
	[ExtID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_usrFLTicketData_IssuedDate]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrFLTicketData_IssuedDate] ON [dbo].[usrFLTicketData]
(
	[IssuedDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_usrFLTicketData_OutletAlphaKey]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_usrFLTicketData_OutletAlphaKey] ON [dbo].[usrFLTicketData]
(
	[OutletAlphaKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
