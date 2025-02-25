USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[cdgfactTraveler]    Script Date: 24/02/2025 12:39:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[cdgfactTraveler](
	[BIRowID] [bigint] IDENTITY(1,1) NOT NULL,
	[factTravelerID] [int] NOT NULL,
	[SessionID] [int] NOT NULL,
	[DOB] [datetime] NULL,
	[IsAdult] [int] NOT NULL,
	[IsChild] [int] NOT NULL,
	[IsInfant] [int] NOT NULL,
	[TreatAsAdultIndicator] [int] NOT NULL,
	[AcceptedOfferIndicator] [int] NOT NULL,
	[EMCAccepted] [int] NOT NULL,
	[Age] [int] NOT NULL,
	[FirstName] [nvarchar](20) NULL,
	[LastName] [nvarchar](20) NULL,
	[Gender] [nvarchar](1) NULL
) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgfactTraveler_BIRowID]    Script Date: 24/02/2025 12:39:35 PM ******/
CREATE CLUSTERED INDEX [idx_cdgfactTraveler_BIRowID] ON [dbo].[cdgfactTraveler]
(
	[BIRowID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgfactTraveler_DOB]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgfactTraveler_DOB] ON [dbo].[cdgfactTraveler]
(
	[DOB] ASC
)
INCLUDE([factTravelerID],[SessionID],[IsAdult],[IsChild],[AcceptedOfferIndicator],[EMCAccepted],[Age],[FirstName],[LastName],[Gender]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgfactTraveler_factTravelerID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgfactTraveler_factTravelerID] ON [dbo].[cdgfactTraveler]
(
	[factTravelerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [idx_cdgfactTraveler_SessionID]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx_cdgfactTraveler_SessionID] ON [dbo].[cdgfactTraveler]
(
	[SessionID] ASC
)
INCLUDE([BIRowID],[factTravelerID],[DOB],[IsAdult],[IsChild],[IsInfant],[TreatAsAdultIndicator],[AcceptedOfferIndicator],[EMCAccepted],[Age],[FirstName],[LastName],[Gender]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
