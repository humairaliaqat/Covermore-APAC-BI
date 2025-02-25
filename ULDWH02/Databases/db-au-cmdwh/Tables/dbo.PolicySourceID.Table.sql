USE [db-au-cmdwh]
GO
/****** Object:  Table [dbo].[PolicySourceID]    Script Date: 24/02/2025 12:39:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PolicySourceID](
	[Country] [varchar](2) NOT NULL,
	[PolicyNo] [int] NOT NULL,
	[OldPolicyNo] [int] NULL,
	[AgencyCode] [varchar](7) NULL,
	[PolicyID] [int] NOT NULL,
	[DepartureDate] [datetime] NULL,
	[ReturnDate] [datetime] NULL,
	[GroupPolicy] [bit] NOT NULL,
	[Suburb] [varchar](30) NULL,
	[State] [varchar](20) NULL,
	[PostCode] [varchar](50) NULL,
	[AddressCountry] [varchar](20) NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx]    Script Date: 24/02/2025 12:39:37 PM ******/
CREATE NONCLUSTERED INDEX [idx] ON [dbo].[PolicySourceID]
(
	[PolicyNo] ASC,
	[Country] ASC
)
INCLUDE([OldPolicyNo],[AgencyCode],[PolicyID],[DepartureDate],[ReturnDate],[GroupPolicy],[Suburb],[State],[PostCode],[AddressCountry]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
